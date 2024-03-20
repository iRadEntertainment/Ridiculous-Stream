# ============================ #
#            dock.gd           #
# ============================ #
@tool
extends PanelContainer
class_name RSDock

var main : RSMain



func start():
	connect_gift_signals()
	%pnl_chat.main = main
	%pnl_chat.start()
	%pnl_co_pilot.main = main
	%pnl_co_pilot.start()


func connect_gift_signals():
	#if !main.gift.is_started:
		#await main.gift.started
	if !main.gift.chat_message.is_connected(play_notification):
		main.gift.chat_message.connect(play_notification)
	if !main.gift.started.is_connected(start):
		main.gift.started.connect(start)


func play_notification(sender_data : SenderData, _message : String):
	if !get_parent(): return
	var new_notif_inst = RSGlobals.msg_notif_pack.instantiate()
	new_notif_inst.username = sender_data.user
	new_notif_inst.main = main
	get_parent().add_child(new_notif_inst)
	new_notif_inst.play()


func _on_btn_hot_reload_plugin_pressed():
	main.reload_plugin()
func _on_btn_start_gift_connections_pressed():
	main.gift.start_connections()
func _on_btn_open_sett_wind_pressed():
	main.wn_settings.popup_centered_clamped()




# TEST: remove test stuff
func _on_btn_test_stuff_pressed():
	main.custom.raid_a_random_streamer_from_the_user_list()
