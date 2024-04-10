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
var center_node : Control
var wheel : Control

var wheel_radius : float = 384
var angle_init = -PI/2
const RES_TOTAL = 100
var streamers_live_data : Dictionary


func _ready():
	set_process(false)

func start() -> void:
	center_node = %center_node
	wheel = %wheel
	build_arrow_indicator()
	build_entire_wheel()


func spin_for_streamers() -> void:
	var rand_angle = randf() * TAU
	rand_angle += TAU * 1
	
	set_process(true)
	var tw = create_tween()
	tw.finished.connect(select_winner_from_wheel)
	tw.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT)
	tw.tween_property(wheel, "rotation", -rand_angle, 15)


func _process(delta):
	pass

func select_winner_from_wheel():
	set_process(false)
	var streamers : Array = streamers_live_data.keys()
	var final_angle = wrap(-wheel.rotation, 0, TAU)
	var selected := floor((final_angle/TAU) * streamers.size() )
	var winner : TwitchStream = streamers_live_data[streamers[selected]]
	
	main.twitcher.api.start_a_raid(
		str(RSSettings.broadcaster_id),
		str(winner.user_id),
		)


func build_entire_wheel() -> void:
	center_node.rotation = 0
	wheel.rotation = 0
	var angle_size = TAU/(streamers_live_data.size())
	#@warning_ignore("integer_division")
	var res = RES_TOTAL/(streamers_live_data.size())
	var i = 0
	var streamers : Array = streamers_live_data.keys()
	for key in streamers:
		var streamer_info : TwitchStream = streamers_live_data[key]
		var angle = angle_init + angle_size * i
		var sector := await wheel_sector(streamer_info, angle, angle_size, wheel_radius, res)
		sector.color = Color(randf(), randf(), randf())#colours[wrap(i, 0, colours.size())]
		wheel.add_child(sector)
		i += 1


func build_arrow_indicator():
	var arrow_poly := Polygon2D.new()
	arrow_poly.color = Color.CRIMSON
	var arrow_radius = 30
	var points = []
	for i in 3:
		var angle = PI + (TAU/3)*i
		var p =  Vector2.from_angle(angle) * arrow_radius
		p += Vector2.RIGHT * wheel_radius
		points.append(p)
	arrow_poly.polygon = points
	arrow_poly.rotation = angle_init
	center_node.add_child(arrow_poly)

func spin_values(values : Array[String], callable : Callable) -> void:
	
	pass


func build_wheel_values(values : Array[String]) -> void:
	
	pass


func wheel_sector(_streamer_info : TwitchStream, _angle_init : float, _angle_size : float, _radius : float, res : int) -> Polygon2D:
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
	
	#var user : RSTwitchUser = main.known_users[_streamer_info.user_login]
	#new_polygon.texture = await main.loader.load_texture_from_url(user.profile_image_url)
	#new_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	
	var line := Line2D.new()
	line.points = points
	line.width = 10 #px
	line.closed = true
	line.antialiased = true
	line.default_color = Color.WHITE_SMOKE
	new_polygon.add_child(line)
	
	var lb := Label.new()
	lb.text = _streamer_info.user_name
	lb.rotation = _angle_init + _angle_size/2
	lb.position = Vector2.from_angle(lb.rotation) * 64
	new_polygon.add_child(lb)
	return new_polygon


func _on_btn_kill_pressed():
	queue_free()
