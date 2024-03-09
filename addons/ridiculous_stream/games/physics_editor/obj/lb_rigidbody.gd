# lb_rigidbody.gd
@tool
extends RigidBody2D


var lb_size : Vector2
var poly_points : PackedVector2Array
var tex : Texture2D

var physics_scene : RSPhysics




func start():
	$poly.polygon = poly_points
	$poly.texture = tex
	$poly.position = -lb_size/2.0
	
	#var rect_coll = RectangleShape2D.new()
	var capsule_coll = CapsuleShape2D.new()
	capsule_coll.radius = lb_size.y/2
	capsule_coll.height = lb_size.x
	#rect_coll.size = lb_size
	$coll.shape = capsule_coll


func destroy():
	if physics_scene:
		RSPhysicsShardGenerator.generate_shards(physics_scene, self, poly_points, tex, 20, 50.0)
	queue_free()







