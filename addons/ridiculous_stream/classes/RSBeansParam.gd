@tool
extends Resource
class_name RSBeansParam


var img_paths : Array = []
var sfx_paths : Array = []
var spawn_range : Array = [3, 5]
var coll_layer : int = 4
var coll_mask : int = 5
var sfx_volume : int = 0
var is_destroy : bool
var is_pickable : bool
var is_poly_fracture : bool
var scale : Vector2 = Vector2.ONE
var destroy_shard_params : RSBeansParam


func to_dict() -> Dictionary:
	var d = {}
	d["img_paths"] = img_paths
	d["sfx_paths"] = sfx_paths
	d["spawn_range"] = spawn_range
	d["coll_layer"] = coll_layer
	d["coll_mask"] = coll_mask
	d["sfx_volume"] = sfx_volume
	d["is_destroy"] = is_destroy
	d["is_pickable"] = is_pickable
	d["is_poly_fracture"] = is_poly_fracture
	d["scale"] = [scale.x, scale.y]
	if destroy_shard_params:
		d["destroy_shard_params"] = destroy_shard_params.to_dict()
	else:
		d["destroy_shard_params"] = null
	return d


func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(d: Dictionary) -> RSBeansParam:
	var param := RSBeansParam.new()
	param.img_paths = d["img_paths"]
	param.sfx_paths = d["sfx_paths"]
	param.spawn_range = d["spawn_range"]
	param.coll_layer = d["coll_layer"]
	param.coll_mask = d["coll_mask"]
	param.sfx_volume = d["sfx_volume"]
	param.is_destroy = d["is_destroy"]
	param.is_pickable = d["is_pickable"]
	param.is_poly_fracture = d["is_poly_fracture"]
	param.scale = Vector2(d["scale"][0], d["scale"][1])
	if d["destroy_shard_params"] != null:
		param.destroy_shard_params = RSBeansParam.from_json(d["destroy_shard_params"])
	return param


