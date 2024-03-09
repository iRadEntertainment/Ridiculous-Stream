@tool
extends PanelContainer

# pnl_test

var main : RSMain


func start():
	pass


func _on_btn_beans_pressed():
	main.custom.beans("redston4d")
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
func _on_btn_load_image_pressed():
	var url = ""
	while url == "":
		var key = main.globals.known_users.keys().pick_random()
		var user := main.globals.known_users[key] as RSTwitchUser
		if user.profile_image_url != "":
			url = user.profile_image_url
	var tex := await main.loader.load_texture_from_url(url)
	%prev_load_image.texture = tex




