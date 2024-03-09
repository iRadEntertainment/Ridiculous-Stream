# panel twitch users
@tool
extends PanelContainer

var main : RSMain

signal user_selected(user)


func start():
	populate_user_button_list()


func populate_user_button_list():
	%ln_filter.text = ""
	await get_tree().create_timer(0.5).timeout
	for btn in %user_list.get_children():
		btn.queue_free()
	#main.load_known_user()
	for username in main.globals.known_users.keys():
		var user := main.globals.known_users[username] as RSTwitchUser
		if not user: continue
		var btn_user_instance = RSGlobals.btn_user_pack.instantiate()
		btn_user_instance.main = main
		btn_user_instance.user = user
		var profile_pic = await main.loader.load_texture_from_url(user.profile_image_url)
		btn_user_instance.profile_pic = profile_pic
		btn_user_instance.start()
		btn_user_instance.user_selected.connect(user_selected_pressed)
		%user_list.add_child(btn_user_instance)


## Called by btn_user_instance
func user_selected_pressed(user : RSTwitchUser):
	%ln_filter.text = ""
	user_selected.emit(user)


func _on_btn_check_live_pressed():
	var check_usernames = main.globals.known_users.keys()
	var live = await main.gift.get_live_streamers(check_usernames)
	print(live)
	for user_button in %user_list.get_children():
		user_button.is_live = user_button.user.username in live
	%tmr_led.start()
	%led.modulate = Color("#c63a00")


func _on_btn_reload_pressed():
	populate_user_button_list()
func _on_ln_filter_text_changed(new_text : String):
	new_text = new_text.to_lower()
	for user_line in %user_list.get_children():
		user_line.visible = user_line.user.username.find(new_text) != -1 or new_text.is_empty()

func _on_tmr_led_timeout():
	%led.modulate = Color("#727272")










