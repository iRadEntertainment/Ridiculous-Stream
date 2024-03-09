extends RigidBody2D

var main : RSMain
var physics_scene : RSPhysics


func start():
	$sprite.texture = main.loader.load_texture_from_data_folder("can.png")

func _on_body_entered(body):
	if linear_velocity.length_squared() > pow(150, 2):
		play_random_sfx()
	if linear_velocity.length_squared() > pow(3000, 2):
		destroy()
		return


func play_random_sfx():
	$sfx.stream = main.loader.load_sfx_from_sfx_folder("sfx_can_%02d.ogg"%[randi_range(1,4)])
	$sfx.pitch_scale = randf_range(0.95, 1.05)
	$sfx.play()


func destroy():
	for i in randi_range(30, 55):
		var bean = main.loader.load_rigid_body_instance_from_obj_folder("bean")
		var pos = position + Vector2.ONE.rotated(randf_range(0, TAU)) * randf_range(40, 80)
		physics_scene.call_deferred("add_rigid", bean, pos)
	
	queue_free()























