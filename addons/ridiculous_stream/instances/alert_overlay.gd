@tool
extends Control
class_name RSAlertOverlay

var main : RSMain

@onready var alert = %alert
@onready var tmr_stop_stream = %tmr_stop_stream
@onready var user_stopped_stream = %user_stopped_stream
@onready var seconds_left = %seconds_left
@onready var progress_time_left = %progress_time_left

@onready var stop_stream_bar = %stop_stream_bar
@onready var random_raid = %random_raid


func _ready():
	set_process(false)

func start():
	stop_stream_bar.hide()
	random_raid.hide()


func initialize_stop_streaming(username : String) -> void:
	alert.play()
	stop_stream_bar.show()
	tmr_stop_stream.timeout.connect(finally_shut_down_the_stream)
	user_stopped_stream.text = username
	progress_time_left.max_value = tmr_stop_stream.wait_time
	progress_time_left.value = tmr_stop_stream.wait_time
	tmr_stop_stream.start()
	set_process(true)


func _process(d):
	progress_time_left.value = tmr_stop_stream.time_left


func finally_shut_down_the_stream():
	main.custom.stop_streaming()
	queue_free()


func _on_btn_close_pressed():
	queue_free()
