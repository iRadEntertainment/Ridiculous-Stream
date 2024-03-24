@tool
extends PanelContainer

# pnl_test

var main : RSMain


func start():
	pass


func _on_btn_beans_pressed():
	main.custom.beans("redston4d")
func _on_btn_zero_g_pressed():
	main.custom.zero_g()
func _on_btn_pickles_pressed():
	main.custom.beans("jakeblade")
func _on_btn_names_pressed():
	main.custom.destructibles_names(await main.loader.load_userfile("pgorley"))
func _on_btn_laser_pressed():
	main.custom.laser()
func _on_btn_crt_pressed():
	main.custom.start_screen_shader(RSShaders.FxType.CRT, 10)
func _on_btn_old_pressed():
	main.custom.start_screen_shader(RSShaders.FxType.OLD, 10)
func _on_btn_speed_pressed():
	main.custom.start_screen_shader(RSShaders.FxType.SPEED, 10)
func _on_btn_re_add_gift_commands_pressed():
	main.custom.add_commands()
func _on_btn_send_message_to_pressed():
	var msg = %message_to_channel.text
	var channel = %channel_name.text
	main.gift.irc.chat(msg, channel)
func _on_btn_load_image_pressed():
	var url = ""
	while url == "":
		var key = main.globals.known_users.keys().pick_random()
		var user := main.globals.known_users[key] as RSTwitchUser
		if user.profile_image_url != "":
			url = user.profile_image_url
	var tex := await main.loader.load_texture_from_url(url)
	%prev_load_image.texture = tex










