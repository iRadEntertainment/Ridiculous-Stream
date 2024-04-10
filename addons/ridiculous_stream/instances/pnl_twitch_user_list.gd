# panel twitch users
@tool
extends PanelContainer

var main : RSMain
var streamers_live_data : Dictionary

signal user_selected(user, live_data)


func start():
	populate_user_button_list()


func populate_user_button_list():
	%ln_filter.text = ""
	await get_tree().create_timer(0.5).timeout
	if main.twitcher.is_connected_to_twitch:
		streamers_live_data = await main.twitcher.get_live_streamers_data()
	for btn in %user_list.get_children():
		btn.queue_free()
	
	for username in main.known_users.keys():
		var user := main.known_users[username] as RSTwitchUser
		if not user: continue
		var btn_user_instance = RSGlobals.btn_user_pack.instantiate()
		btn_user_instance.main = main
		btn_user_instance.user = user
		var profile_pic = await main.loader.load_texture_from_url(user.profile_image_url)
		btn_user_instance.profile_pic = profile_pic
		btn_user_instance.user_selected.connect(user_selected_pressed)
		%user_list.add_child(btn_user_instance)
		if username in streamers_live_data.keys():
			btn_user_instance.live_data = streamers_live_data[username]
		btn_user_instance.start()


## Called by btn_user_instance
func user_selected_pressed(user : RSTwitchUser, live_data : TwitchStream):
	%ln_filter.text = ""
	user_selected.emit(user, live_data)


func _on_btn_filter_live_pressed():
	for user_button in %user_list.get_children():
		user_button.visible = user_button.user.username in streamers_live_data.keys()
#func _on_btn_check_live_pressed():
	#var live_data := await main.gift.get_live_streamers_data()
	#
	#for user_button in %user_list.get_children():
		#user_button.visible = user_button.user.username in live_data.keys()
		#if user_button.user.username in live_data.keys():
			#user_button.live_data = live_data[user_button.user.username]
		#else:
			#user_button.live_data = null

func _on_btn_reload_pressed():
	populate_user_button_list()
func _on_ln_filter_text_changed(new_text : String):
	new_text = new_text.to_lower()
	for user_line in %user_list.get_children():
		user_line.visible = user_line.user.username.find(new_text) != -1 or new_text.is_empty()



