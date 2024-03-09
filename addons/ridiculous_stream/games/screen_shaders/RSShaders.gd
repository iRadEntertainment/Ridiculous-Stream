@tool
extends Control
class_name RSShaders

enum FxType{CRT, OLD, SPEED}
var already_playing = {}


const fx_list =[
	preload("res://addons/ridiculous_stream/shaders/crt.material"),
	preload("res://addons/ridiculous_stream/shaders/old_movie.material"),
	preload("res://addons/ridiculous_stream/shaders/speed_lines.material")
]


func _ready():
	set_process(false)

func play(fx_type : FxType, duration := 10.0):
	resize()
	if fx_type in already_playing.keys():
		already_playing[fx_type]["duration"] += duration
		return
	
	var node := ColorRect.new()
	node.color = Color.WHITE
	node.name = FxType.find_key(fx_type)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.material = fx_list[fx_type]
	add_child(node)
	node.set_deferred("size", size)
	already_playing[fx_type] = {"duration" : duration, "node": node}
	set_process(true)


func _process(d):
	if already_playing.is_empty():
		set_process(false)
		queue_free()
		return
	
	for fx_type in already_playing.keys():
		already_playing[fx_type]["duration"] -= d
		if already_playing[fx_type]["duration"] <= 0.0:
			already_playing[fx_type]["node"].queue_free()
			already_playing.erase(fx_type)



func resize():
	var boundary_thickness = 100
	var off = boundary_thickness/2
	var ce = get_parent()
	var new_size = ce.get_rect().size
	set_deferred("size",  new_size)
