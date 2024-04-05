# ============================ #
#            dock.gd           #
# ============================ #
@tool
extends PanelContainer
class_name RSDock

var main : RSMain


func start():
	connect_twitcher_signals()
	for pnl in [%pnl_chat, %pnl_co_pilot, %pnl_quick_actions]:
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
	main.custom.add_commands()
	#main.loader.convert_all_users()
	# main.twitcher.set_broadcaster_id_for_all_eventsub(456)
	#main.custom.raid_a_random_streamer_from_the_user_list()
