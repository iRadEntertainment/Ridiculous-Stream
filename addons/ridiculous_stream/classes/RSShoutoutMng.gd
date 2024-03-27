@tool
extends Node
class_name RSShoutoutMng

var main : RSMain
var queued_user_shoutout : Array[RSTwitchUser] = []
var already_shoutout_list : Array[RSTwitchUser] = []
var last_shoutout_unix : int
const SHOUTOUT_COOLDOWN = 125 #sec
const SHOUTOUT_COOLDOWN_SAME_USER = 3600 #sec


func _ready():
	set_process(false)

func start():
	set_process(true)


func _process(delta):
	if queued_user_shoutout.is_empty():
		set_process(false)
		return
	
	var current_unix_time = Time.get_unix_time_from_system()
	if current_unix_time < last_shoutout_unix + SHOUTOUT_COOLDOWN: return
	
	
	var next_user = queued_user_shoutout.pop_front()
	already_shoutout_list.append(next_user)
	give_shoutout(next_user)


func give_shoutout(user : RSTwitchUser):
	main.twitcher.api.send_a_shoutout(
		str(main.settings.broadcaster_id),
		str(user.user_id),
		str(main.settings.broadcaster_id),
		)
	if user.shoutout_description != "":
		main.twitcher.chat(user.shoutout_description)


func add_shoutout(user : RSTwitchUser):
	if !user.is_streamer:
		print("RSShoutoutMng: %s is not a streamer according to your list!"%[user.display_name])
		return
	if user in queued_user_shoutout:
		print("RSShoutoutMng: %s is already in the queue!"%[user.display_name])
		return
	if user in already_shoutout_list:
		print("RSShoutoutMng: %s already got a shoutout today!"%[user.display_name])
		return
	queued_user_shoutout.append(user)
	set_process(true)


