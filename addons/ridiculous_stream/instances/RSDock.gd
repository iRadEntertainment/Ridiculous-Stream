# ============================ #
#            dock.gd           #
# ============================ #
@tool
extends PanelContainer
class_name RSDock

var main: RSMain
@onready var pnl_mods = %pnl_mods
@onready var pnl_quick_actions = %pnl_quick_actions
@onready var pnl_co_pilot = %pnl_co_pilot
@onready var pnl_chat = %pnl_chat


func start():
	connect_twitcher_signals()
	for pnl in [pnl_chat, pnl_co_pilot, pnl_quick_actions, pnl_mods]:
		pnl.main = main
		pnl.start()


func connect_twitcher_signals():
	if !main.twitcher.received_chat_message.is_connected(play_notification):
		main.twitcher.received_chat_message.connect(play_notification)
	if !main.twitcher.connected_to_twitch.is_connected(start):
		main.twitcher.connected_to_twitch.connect(start)


func play_notification(_channel_name: String, username: String, _message: String, _tags: TwitchTags.PrivMsg):
	if !get_parent(): return
	var new_notif_inst = RSGlobals.msg_notif_pack.instantiate()
	new_notif_inst.username = username
	new_notif_inst.main = main
	get_parent().add_child(new_notif_inst)
	new_notif_inst.play()


func _on_btn_reload_pressed():
	main.call_deferred("reload_dock")
# TEST: remove test stuff
func _on_btn_test_stuff_pressed():
	for user in main.known_users:
		print(main.known_users.display_name)
	#var followers : int = await main.twitcher.get_follower_count()
	#var mods : Array[TwitchUserModerator] = await main.twitcher.get_moderators()
	#print("Followers: ", followers)
	#print("Mods: ", mods.size())
	
