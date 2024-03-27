@tool
extends Control
class_name RSAlertOverlay

var main : RSMain

@onready var alert = %alert
@onready var tmr_progress = %tmr_progress
@onready var user_stopped_stream = %user_stopped_stream
@onready var seconds_left = %seconds_left
@onready var progress_time_left = %progress_time_left

@onready var user_start_raid = %user_start_raid
@onready var raided_username = %raided_username
@onready var progress_time_left_raid = %progress_time_left_raid

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
	tmr_progress.timeout.connect(finally_shut_down_the_stream)
	user_stopped_stream.text = username
	progress_time_left.max_value = tmr_progress.wait_time
	progress_time_left.value = tmr_progress.wait_time
	tmr_progress.start()
	set_process(true)


func initialize_raid(username : String, _raided_user : RSTwitchUser) -> void:
	alert.play()
	random_raid.show()
	user_start_raid.text = username
	raided_username.text = _raided_user.username
	tmr_progress.wait_time = 10
	progress_time_left_raid.max_value = tmr_progress.wait_time
	progress_time_left_raid.value = tmr_progress.wait_time
	tmr_progress.start()
	set_process(true)
	await tmr_progress.timeout
	main.twitcher.api.start_a_raid(
		str(main.settings.broadcaster_id),
		str(_raided_user.user_id),
		)
	queue_free()


func _process(d):
	progress_time_left.value = tmr_progress.time_left
	seconds_left.text = "%d"%tmr_progress.time_left
	progress_time_left_raid.value = tmr_progress.time_left


func finally_shut_down_the_stream():
	main.custom.stop_streaming()
	queue_free()


func _on_btn_close_pressed():
	queue_free()
