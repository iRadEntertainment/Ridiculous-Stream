@tool
extends PanelContainer
class_name RSNotificationVettingReward

@onready var cnt_warnings = %cnt_warnings
@onready var title = %title
@onready var msg = %msg
@onready var username = %username
@onready var warn_count = %warn_count

var vetting : RSVetting
var callable : Callable
var data : RSTwitchEventData
var warnings : int = 0


func start():
	if not data: return
	title.text = data.reward_title
	msg.visible = !(data.user_input.is_empty() or data.user_input == null)
	msg.text = data.user_input
	username.text = data.username
	warn_count.text = str(warnings)
	cnt_warnings.visible = warnings > 0

func send_response(response: RSVetting.Responses):
	vetting.receive_response(callable, data, response)
	queue_free()

func _on_btn_accept_all_pressed():
	send_response(RSVetting.Responses.ACCEPT_ALL)
func _on_btn_accept_pressed():
	send_response(RSVetting.Responses.ACCEPT)
func _on_btn_warn_pressed():
	send_response(RSVetting.Responses.DECLINE_WARN)
func _on_btn_decline_pressed():
	send_response(RSVetting.Responses.DECLINE)
func _on_btn_decline_all_pressed():
	send_response(RSVetting.Responses.DECLINE_ALL)
