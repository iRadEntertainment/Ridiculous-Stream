@tool
extends RigidBody2D
class_name ImageToRigid

var main : RSMain
var physics_scene : RSPhysics

var sprite_scale := Vector2(1,1)
var sprite : Sprite2D
var coll : CollisionShape2D
var shape : CapsuleShape2D

var tex : Texture2D
var params : RSBeansParam
var sfx_streams : Array[AudioStream]


func _init(_tex : Texture2D, _params : RSBeansParam, _sfx_streams : Array[AudioStream]):
	tex = _tex
	params = _params
	sfx_streams = _sfx_streams
	set_nodes()
	collision_layer = params.coll_layer
	collision_mask = params.coll_mask
	contact_monitor = true
	max_contacts_reported = 1
	mass = 0.25
	var phys_mat := PhysicsMaterial.new()
	phys_mat.friction = 0.8
	phys_mat.bounce = 0.2
	physics_material_override = phys_mat
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if not physics_scene.is_sfx_free(): return
	if linear_velocity.length_squared() > pow(250, 2):
		if !sfx_streams.is_empty():
			play_random_sfx()
	#if linear_velocity.length_squared() > pow(3000, 2) and params.is_destroy:
		#destroy()


func play_random_sfx():
	var stream : AudioStream = sfx_streams.pick_random()
	physics_scene.play_sfx(stream, params.sfx_volume)


func destroy():
	if params.destroy_shard_params:
		var new_p : RSBeansParam = params.destroy_shard_params
		var shards_num = range(new_p.spawn_range[0], new_p.spawn_range[1]).pick_random()
		physics_scene.add_image_bodies(new_p, position)
	queue_free()


func set_nodes():
	var dim = tex.get_image().get_size()
	sprite = Sprite2D.new()
	sprite.texture = tex
	sprite.scale = params.scale
	add_child(sprite)
	coll = CollisionShape2D.new()
	coll.visible = false
	shape = CapsuleShape2D.new()
	coll.shape = shape
	if dim.x > dim.y:
		coll.rotation = PI/2
		shape.height = dim.x * params.scale.x * 0.9
		shape.radius = dim.y/2.0 * params.scale.y * 0.9
	else:
		shape.height = dim.y * params.scale.y * 0.9
		shape.radius = dim.x/2.0 * params.scale.x * 0.9
	add_child(coll)













