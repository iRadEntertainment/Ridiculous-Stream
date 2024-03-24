@tool
extends Control
class_name RSPhysics

var laser_scene

var main : RSMain

var parent
var code_edit : CodeEdit
var duration = 15.0 #s
var joint_rid : RID

var is_closing := false


func start():
	parent = get_parent()
	if parent is Control:
		parent.resized.connect(resize_boundaries)
		#parent.gui_input.connect(gui_input)
	if EditorInterface.get_script_editor().get_current_editor():
		code_edit = EditorInterface.get_script_editor().get_current_editor().get_base_editor()
		if code_edit:
			code_edit.caret_changed.connect(shuffle_bodies)
	is_closing = false
	resize_boundaries(true)
	reset_timers()
	start_physics()


func reset_timers():
	$tmr_disable.wait_time = duration
	$tmr_disable.start()
	$tmr_kill.wait_time = duration + 3.0
	$tmr_kill.start()


func _process(delta):
	if parent:
		var fill = (duration-$tmr_disable.time_left)/duration
		$btn_kill.material.set_shader_parameter("fill_ratio", fill)
		$pick_dummy.position = parent.get_local_mouse_position()


func resize_boundaries(is_start := false):
	if is_start:
		$boundaries/s.position = parent.size
		$boundaries/e.position = parent.size
	else:
		var tw = create_tween()
		tw.set_ease(Tween.EASE_IN_OUT)
		tw.set_trans(Tween.TRANS_CUBIC)
		tw.tween_property($boundaries/s, "position", parent.size, 0.8)
		tw.parallel()
		tw.tween_property($boundaries/e, "position", parent.size, 0.8)


func add_rigid(new_body : RigidBody2D, pos := Vector2(), linear_velocity := Vector2(), angular_velocity := 0.0, pickable := false):
	reset_timers()
	# input from the body
	if pickable:
		var control_picker := Control.new()
		var coll_rect := Rect2()
		for coll in new_body.get_children():
			if coll is CollisionPolygon2D:
				for p in coll.polygon:
					if p.x < coll_rect.position.x:
						coll_rect.position.x = p.x
					if p.y < coll_rect.position.y:
						coll_rect.position.y = p.y
					if p.x > coll_rect.end.x:
						coll_rect.end.x = p.x
					if p.y > coll_rect.end.y:
						coll_rect.end.y = p.y
				break
			elif coll is CollisionShape2D:
				if new_body.has_method("start"):
					new_body.start()
				coll_rect = coll.shape.get_rect()
				coll_rect *= Transform2D(coll.rotation, Vector2() )
				break
		
		control_picker.position = coll_rect.position
		control_picker.size = coll_rect.size
		control_picker.gui_input.connect(obj_input.bind(new_body))
		
		new_body.add_child(control_picker)
	
	# position and physics
	var safe = 60
	if pos == Vector2():
		pos.x = clamp(randf_range(0, size.x), safe, size.x - safe)
		pos.y = clamp(randf_range(0, size.y), safe, size.y - safe)
	new_body.position = pos
	new_body.linear_velocity = linear_velocity
	new_body.angular_velocity = angular_velocity
	
	# finalizing
	for dic in new_body.get_property_list():
		if "physics_scene" == dic.name:
			new_body.physics_scene = self
			break
	$bodies.add_child(new_body)
	new_body.add_to_group("editor_bodies")
	new_body.owner = $bodies.owner
	if new_body.has_method("start"):
		new_body.start()
	add_body_to_space(new_body)


func generate_text_rigidbody(text : String, col : Color):
	var lb_body : RigidBody2D = await $label_renderer.generate_text_rigidbody(text, col)
	lb_body.mass = 0.3
	var safe = 120
	var pos = Vector2(randf_range(safe ,size.x-safe*3), randf_range(safe, safe*3))
	var linear_velocity = Vector2((randf()-0.5)*30, (randf()-0.5)*30)
	var angular_velocity = (randf()-0.5)*10
	call_deferred("add_rigid", lb_body, pos, linear_velocity, angular_velocity, true)


func add_image_bodies(params : Dictionary, pos = null, linear_velocity = null, angular_velocity = null):
	if params.img_paths.is_empty():
		print("RSPhysics: no image passed to 'add_image_bodies()'")
		return
	var texs : Array[Texture2D] = []
	for tex_path in params.img_paths:
		if tex_path.is_empty(): continue
		texs.append(await main.loader.load_texture_from_data_folder(tex_path))
	
	var sfx_streams : Array[AudioStream] = []
	for sfx_path in params.sfx_paths:
		if sfx_path.is_empty(): continue
		sfx_streams.append(await main.loader.load_sfx_from_sfx_folder(sfx_path))
	
	var num = range(params.spawn_range[0], params.spawn_range[1]+1).pick_random()
	for i in num:
		var tex = texs.pick_random()
		var body : ImageToRigid = ImageToRigid.new(tex, params, sfx_streams)
		var final_pos := Vector2()
		if not pos:
			var safe = 120
			final_pos = Vector2(randf_range(safe , size.x-safe*3), randf_range(safe, safe*3))
		else:
			final_pos = pos + Vector2.ONE.rotated(randf_range(0, TAU)) * randf_range(40, 80)
		if not linear_velocity:
			linear_velocity = Vector2((randf()-0.5)*30, (randf()-0.5)*30)
		if not angular_velocity:
			angular_velocity = (randf()-0.5)*10
		
		add_rigid(body, final_pos, linear_velocity, angular_velocity, true)


func add_laser():
	if not laser_scene:
		laser_scene = main.globals.laser_scene_pack.instantiate()
		laser_scene.physics_scene = self
		laser_scene.position = size/2
		laser_scene.physics_space_rid = main.globals.physics_space_rid
		add_child(laser_scene)
		laser_scene.play()
	else:
		laser_scene.replay()


func obj_input(event, obj : RigidBody2D): # input event rigid body
	if not joint_rid: return
	if event is InputEventMouseButton:
		# Pick object
		if event.button_index == MOUSE_BUTTON_LEFT:
			var is_picked = event.is_pressed()
			obj.angular_damp = 10 if is_picked else 2
			if is_picked:
				var anchor_pos = parent.get_global_mouse_position()
				PhysicsServer2D.joint_make_pin(joint_rid, anchor_pos, obj.get_rid(), $pick_dummy.get_rid())
			else:
				PhysicsServer2D.joint_clear(joint_rid)
		# destroy object
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				if obj.has_method("destroy"):
					obj.call_deferred("destroy")


func shuffle_bodies():
	if not code_edit: return
	var pos : Vector2 = code_edit.get_caret_draw_pos()
	for body in get_tree().get_nodes_in_group("editor_bodies"):
		body = body as RigidBody2D
		var diff : Vector2 = body.position - pos
		var force = 10000/(diff).length_squared() * body.mass * 40 * diff.normalized()
		body.apply_impulse(force)


func toggle_top_boundary(val : bool):
	$boundaries/n.set_deferred("disabled", !val)


func disable_boundaries():
	is_closing = true
	$boundaries.collision_layer = 0
	$boundaries.collision_mask  = 0
	for body in get_tree().get_nodes_in_group("editor_bodies"):
		body.sleeping = false


func kill():
	stop_physics()
	queue_free()


func start_physics():
	if not main.globals.physics_space_rid:
		main.globals.physics_space_rid = activate_new_space()
	set_new_space_default_param(main.globals.physics_space_rid)
	set_editor_physics(false)
	set_process(true)
	joint_rid = PhysicsServer2D.joint_create()
	add_body_to_space($boundaries)
	add_body_to_space($pick_dummy)
	PhysicsServer2D.space_set_active(main.globals.physics_space_rid, true)
	PhysicsServer2D.set_active(true)


func stop_physics():
	PhysicsServer2D.set_active(false)
	deactivate_space(main.globals.physics_space_rid)
	PhysicsServer2D.space_set_active(main.globals.physics_space_rid, false)
	set_process(false)


# ========================================= UTILITIES ==============================================
## Set the editor direct space to false to prevent physics bodies activation
## in the opened scenes
func set_editor_physics(val : bool) -> void:
	var edit_space_rid := EditorInterface.get_editor_viewport_2d().get_viewport().find_world_2d().get_space()
	PhysicsServer2D.space_set_active(edit_space_rid, val)

## Set a new editor direct space to true and store the rid for later use
## so it is possible to set new bodies space to this one
func activate_new_space() -> RID:
	var rid : RID = PhysicsServer2D.space_create()
	PhysicsServer2D.space_set_active(rid, true)
	return rid
func deactivate_space(space_rid : RID):
	PhysicsServer2D.space_set_active(space_rid, false)

## Set a default values for a physics space
func set_new_space_default_param(space_rid : RID):
	var dir_state := PhysicsServer2D.space_get_direct_state(space_rid)
	var gravity = 4410
	PhysicsServer2D.area_set_param(space_rid, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity)
	PhysicsServer2D.area_set_param(space_rid, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN)
	PhysicsServer2D.area_set_param(space_rid, PhysicsServer2D.AREA_PARAM_LINEAR_DAMP, 0.5)
	PhysicsServer2D.area_set_param(space_rid, PhysicsServer2D.AREA_PARAM_ANGULAR_DAMP, 0.5)


func set_space_gravity(gravity : int = 4410):
	var space_rid = main.globals.physics_space_rid
	var dir_state := PhysicsServer2D.space_get_direct_state(space_rid)
	PhysicsServer2D.area_set_param(space_rid, PhysicsServer2D.AREA_PARAM_GRAVITY, gravity)


func add_body_to_space(body : PhysicsBody2D):
	PhysicsServer2D.body_set_space(body.get_rid(), main.globals.physics_space_rid)
func add_collider_to_space(collider_rid : RID):
	PhysicsServer2D.area_set_space(collider_rid, main.globals.physics_space_rid)
	PhysicsServer2D.body_set_space(collider_rid, main.globals.physics_space_rid)
















