@tool
extends Node
class_name RSPhysicsShardGenerator



static func generate_shards(physics_scene : RSPhysics, body : PhysicsBody2D, poly : Array[Vector2], tex : Texture2D, fracture_number : int, min_discard_area : float):
	var shards = []
	var poly_rect := get_rect_from_poly(poly)
	var size = poly_rect.size
	
	
	var frac_array = PolygonFracture.fractureDelaunayRectangle(poly, body.transform, fracture_number, min_discard_area, RandomNumberGenerator.new())
	shards.clear()
	for dic in frac_array:
		var frac_poly = dic.shape
		var frac_poly_centered = dic.centered_shape
		var frac_centroid = dic.centroid
		var frac_spawn_pos := dic.spawn_pos as Vector2
		
		var shard_body = RigidBody2D.new()
		shard_body.global_position = frac_spawn_pos
		shard_body.collision_layer = 2
		shard_body.collision_mask = 1
		
		var new_poly = Polygon2D.new()
		new_poly.polygon = frac_poly
		new_poly.global_position = -frac_centroid
		new_poly.texture = tex
		
		var coll = CollisionPolygon2D.new()
		coll.polygon = frac_poly_centered
		coll.visible = false
		
		shard_body.add_child(new_poly)
		shard_body.add_child(coll)
		
		shards.append(shard_body)
	
	for i in shards.size():
		var shard = shards[i] as RigidBody2D
		#shard.transform = frac_array[i]["source_global_trans"]
		shard.global_rotation = body.global_rotation
		var frac_spawn_pos := frac_array[i]["spawn_pos"] as Vector2
		var pos = frac_spawn_pos + body.global_position - (size/2).rotated(body.global_rotation)
		physics_scene.add_rigid(shard, pos, Vector2(), 0, false)
		
		var m = body.get_global_mouse_position()
		var dir = (shard.global_position - m).normalized()
		shard.apply_central_impulse(dir*1000)



const MAX_COORD = pow(2,31)-1
const MIN_COORD = -MAX_COORD
static func get_rect_from_poly(poly) -> Rect2:
	var min_vec = Vector2(MAX_COORD,MAX_COORD)
	var max_vec = Vector2(MIN_COORD,MIN_COORD)
	for v in poly:
		min_vec = Vector2(min(min_vec.x, v.x) ,min(min_vec.y, v.y))
		max_vec = Vector2(max(max_vec.x, v.x) ,max(max_vec.y, v.y))
	return Rect2(min_vec,max_vec-min_vec)
