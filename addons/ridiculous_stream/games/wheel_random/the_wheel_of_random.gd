@tool
extends Control
class_name RSWheelOfRandom

const colours = [
	Color.ROSY_BROWN,
	Color.AQUA,
	Color.DEEP_PINK,
	Color.SADDLE_BROWN,
	Color.BLACK,
	Color.SEA_GREEN,
	Color.ORANGE
]

var main : RSMain
var wheel_center : Control

var wheel_radius : float = 384
var angle_init = -PI/2
const RES_TOTAL = 100
var streamers_live_data : Dictionary

func start() -> void:
	wheel_center = %wheel_center


func spin_for_streamers(_streamers_live_data : Dictionary = {}) -> void:
	if not _streamers_live_data.is_empty():
		streamers_live_data = _streamers_live_data
	wheel_center.rotation = 0
	var angle_size = TAU/(streamers_live_data.size())
	#@warning_ignore("integer_division")
	var res = RES_TOTAL/(streamers_live_data.size())
	var i = 0
	var users : Array = streamers_live_data.keys()
	for key in users:
		var streamer_info : RSStreamerInfo = streamers_live_data[key]
		var angle = angle_init + angle_size * i
		var sector := wheel_sector(streamer_info, angle, angle_size, wheel_radius, res)
		sector.color = colours[wrap(i, 0, colours.size())]
		wheel_center.add_child(sector)
		
		i += 1
	
	var rand_angle = randf_range(0, TAU)
	var lerping = lerp(0, users.size(), rand_angle/TAU)
	var selected := int(lerping)
	var winner : RSStreamerInfo = streamers_live_data[users[selected]]
	
	print("users: ", users)
	print("rand_angle: ", rand_angle)
	print("lerping: ", lerping)
	print("selected: ", selected)
	print("winner: ", winner.user_login)
	
	rand_angle += TAU * 1
	rand_angle += angle_init
	var tw = create_tween()
	tw.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tw.tween_property(wheel_center, "rotation", rand_angle, 2)
	#tw.finished.connect(main.gift.start_raid.bind(winner.user_id))


func spin_values(values : Array[String], callable : Callable) -> void:
	
	pass


func build_wheel_values(values : Array[String]) -> void:
	
	pass


func wheel_sector(_streamer_info : RSStreamerInfo, _angle_init : float, _angle_size : float, _radius : float, res : int) -> Polygon2D:
	var new_polygon := Polygon2D.new()
	
	new_polygon.set_meta("streamer_info", _streamer_info)
	var points := PackedVector2Array()
	var angle_step = _angle_size/(res-1)
	points.append(Vector2())
	for i in res:
		var angle = _angle_init + angle_step*i
		var p = Vector2.from_angle(angle) * _radius
		points.append(p)
	new_polygon.polygon = points
	
	#TODO: add a label as a child
	var lb := Label.new()
	lb.text = _streamer_info.user_name
	lb.rotation = _angle_init + _angle_size/2
	lb.position = Vector2.from_angle(lb.rotation) * 64
	new_polygon.add_child(lb)
	return new_polygon


func _on_btn_kill_pressed():
	queue_free()
