@tool
extends Node2D

var duration = 30
var physics_scene : RSPhysics
var tw : Tween
var physics_space_rid : RID
var space : PhysicsDirectSpaceState2D

var query : PhysicsRayQueryParameters2D

func _ready():
	set_process(false)


func play():
	space = PhysicsServer2D.space_get_direct_state(physics_space_rid)
	query = PhysicsRayQueryParameters2D.create(Vector2(), Vector2())
	query.collide_with_bodies = true
	query.collision_mask = 1+2+4+8+16+32
	
	#physics_scene.add_collider_to_space(%ray.get_collider_rid())
	var passes = 5
	var angle = PI/2.85
	set_process(true)
	tw = create_tween().bind_node(self)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_EXPO)
	tw.tween_property(self, "rotation", angle, duration/passes)
	tw.tween_property(self, "rotation", -angle, duration/passes)
	tw.tween_property(self, "rotation", angle, duration/passes)
	tw.tween_property(self, "rotation", -angle, duration/passes)
	tw.tween_property(self, "rotation", 0, duration/passes)
	await tw.finished
	queue_free()

func replay():
	return
	tw.tween_property(self, "rotation", TAU, 3.0)
	await tw.finished
	queue_free()


func _process(delta):
	var firing = not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	query.from = %ray.global_position
	query.to = %ray.global_position + %ray.target_position.rotated(rotation)
	var coll_dic : Dictionary = space.intersect_ray(query)
	var colliding = !coll_dic.is_empty()
	
	%line.visible = colliding#firing
	%line.points[1] = %ray.target_position
	%impact_particles.emitting = colliding and firing
	
	if colliding and firing:
		var impact_pos = coll_dic.position
		var n = coll_dic.normal
		var n_angle = n.angle()
		var coll = coll_dic.collider
		
		%line.points[1].y = (impact_pos - %line.global_position).length()
		%impact_particles.global_position = impact_pos
		%impact_particles.global_rotation = n_angle + PI/2
		
		if coll.has_method("destroy"):
			coll.destroy()
		elif coll is RigidBody2D and firing:
			coll.apply_impulse((Vector2.RIGHT * 30).rotated(n_angle+PI), impact_pos)
		












