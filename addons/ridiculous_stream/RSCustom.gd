extends RefCounted
class_name RSCustom

var main : RSMain

var alert_scene : RSAlertOverlay
var physic_scene : RSPhysics
var screen_shader : RSShaders


func start():
	main.gift.chat_message.connect(on_chat)
	main.gift.whisper_message.connect(on_whisper_message)
	main.gift.user_joined.connect(on_user_joined)
	main.gift.user_parted.connect(on_user_parted)
	main.gift.channel_points_redeemed.connect(on_channel_points_redeemed)
	main.gift.followed.connect(on_followed)
	main.gift.raided.connect(on_raided)
	main.gift.subscribed.connect(on_subscribed)
	main.gift.cheered.connect(on_cheered)
	add_commands()


func add_commands() -> void:
	main.gift.cmd_handler.add_command("laser", laser)
	#main.gift.cmd_handler.add_command("crt", start_screen_shader.bind("crt"))
	#main.gift.cmd_handler.add_command("old", start_screen_shader.bind("old_movie"))
	#main.gift.cmd_handler.add_command("speed", start_screen_shader.bind("speed_lines"))
	#main.gift.cmd_handler.add_command("so", main.shoutout, main.gift.cmd_handler.PermissionFlag.MOD_STREAMER)
	main.gift.cmd_handler.add_command("discord", discord)
	main.gift.cmd_handler.add_command("chat", chat_commands_help)

func on_chat(sender_data : SenderData, message : String):
	pass
func on_whisper_message(sender_data : SenderData, message : String):
	pass
func on_user_joined(sender_data : SenderData):
	pass
func on_user_parted(sender_data : SenderData):
	pass
func on_channel_points_redeemed(data : RSTwitchEventData):
	match data.reward_title:
		"beans":
			beans(data.username)
		"activate copilot for 10 minutes":
			pass
		"crt": start_screen_shader(RSShaders.FxType.CRT, 5.0)
		"speed": start_screen_shader(RSShaders.FxType.SPEED, 120.0)
		"old movie": start_screen_shader(RSShaders.FxType.OLD, 60.0)
		"open useless website": open_useless_website()
		"open browser history": open_browser_history()
		"Activate CoPilot for 5min": activate_copilot(300)
		"remove the cig break overlay": toggle_cig_overlay()
		"Shut down stream": alert_on_stop_streaming(data.username)
		"Raid kani_dev": raid_kani(data.username)
func on_followed(data : RSTwitchEventData):
	pass
func on_raided(data : RSTwitchEventData):
	pass
func on_subscribed(data : RSTwitchEventData):
	pass
func on_cheered(data : RSTwitchEventData):
	pass




func discord(cmd_info : CommandInfo):
	var msg = "Join Discord: https://discord.gg/4YhKaHkcMb"
	main.gift.chat(msg)

func chat_commands_help(cmd_info : CommandInfo):
	var msg = "Use a combination of ![command] for chat: hl (highlight), hd(hidden), rb(rainbow), big, small, wave, pulse, tornado, shake"
	main.gift.chat(msg)

func add_physic_scene():
	if not physic_scene:
		physic_scene = RSGlobals.physic_scene_pack.instantiate()
		EditorInterface.get_base_control().add_child(physic_scene)
		physic_scene.main = main
		physic_scene.start()


func beans(username : String):
	add_physic_scene()
	if physic_scene.is_closing: return
	
	var user := main.get_known_user(username.to_lower()) as RSTwitchUser
	if user:
		if user.custom_beans_params:
			physic_scene.add_image_bodies(user.custom_beans_params)
			return
	
	physic_scene.add_image_bodies(RSGlobals.params_can)


func laser(cmd_info : CommandInfo = null):
	add_physic_scene()
	if physic_scene.is_closing: return
	physic_scene.add_laser()


func destructibles_names(user : RSTwitchUser):
	add_physic_scene()
	if physic_scene.is_closing: return
	#await get_tree().create_timer(0.1).timeout
	
	var col :=  Color("#00ec4f")
	if user.custom_chat_color != Color.BLACK:
		col = user.custom_chat_color
	
	physic_scene.generate_text_rigidbody(user.display_name, col)


func start_screen_shader(fx_type := RSShaders.FxType.CRT, duration := 5.0):
	if !screen_shader:
		screen_shader = RSGlobals.screen_shader_pack.instantiate()
		EditorInterface.get_base_control().add_child(screen_shader)
	screen_shader.play(fx_type, duration)
#endregion


func toggle_cig_overlay():
	var request_type = "GetSceneItemId"
	var request_data = {"scene_name": "Big screen", "source_name": "BRB_text"}
	var request = main.no_obs_ws.make_generic_request(request_type, request_data)
	await request.response_received
	var response = request.message.get_data()
	var item_id = response.response_data.scene_item_id
	request_type = "GetSceneItemEnabled"
	request_data = {"scene_name": "Big screen", "scene_item_id": item_id}
	request = main.no_obs_ws.make_generic_request(request_type, request_data)
	await request.response_received
	response = request.message.get_data()
	var scene_item_enabled = response.response_data.scene_item_enabled
	request_type = "SetSceneItemEnabled"
	request_data = {"scene_name": "Big screen", "scene_item_id": item_id, "scene_item_enabled": !scene_item_enabled}
	main.no_obs_ws.make_generic_request(request_type, request_data)



func alert_on_stop_streaming(username):
	if not alert_scene:
		alert_scene = RSGlobals.alert_scene_pack.instantiate()
		EditorInterface.get_base_control().add_child(alert_scene)
		alert_scene.main = main
		alert_scene.start()
		alert_scene.initialize_stop_streaming(username)


func stop_streaming():
	# obs_frontend_streaming_stop
	var request_type = "StopStream"
	var request_data = {}
	var request = main.no_obs_ws.make_generic_request(request_type, request_data)
	await request.response_received
	print(request.message)


func raid_kani(username : String):
	var kani_rs_user := main.get_known_user("kani_dev")
	alert_scene = RSGlobals.alert_scene_pack.instantiate()
	EditorInterface.get_base_control().add_child(alert_scene)
	alert_scene.main = main
	alert_scene.start()
	alert_scene.initialize_raid(username, kani_rs_user)


func raid_a_random_streamer_from_the_user_list():
	return
	#var online_streamers := await main.gift.get_live_streamers()
	#print("Online streamers:")
	#print(online_streamers)


func save_all_scenes_and_scripts():
	pass

func open_useless_website():
	OS.shell_open("https://theuselessweb.com/")
func open_browser_history():
	OS.execute("C:/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe", ['about:history'])
func activate_copilot(secondos : float):
	main.copilot.activate(secondos)
func open_silent_itch_io_page():
	pass
func play_carbrix_or_woop():
	pass
func play_kerker():
	OS.execute("C:\\Users\\Dario\\Desktop\\Kerker.exe", [])











