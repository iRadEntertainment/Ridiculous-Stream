extends RefCounted
class_name RSCustom

var main : RSMain
var log : RSLogger

var alert_scene : RSAlertOverlay
var physic_scene : RSPhysics
var physics_space_rid: RID
var screen_shader : RSShaders
var wheel_of_random : RSWheelOfRandom

const STREAM_OVERLAY_SCENE = "Stream Overlays"
const STREAM_OVERLAY_VIDEOS = "Overlay videos"

func start() -> void:
	log = RSLogger.new(RSSettings.LOGGER_NAME_CUSTOM)
	log.i("Started")
	main.twitcher.received_chat_message.connect(on_chat)
	main.twitcher.channel_points_redeemed.connect(on_channel_points_redeemed)
	main.twitcher.followed.connect(on_followed)
	main.twitcher.raided.connect(on_raided)
	main.twitcher.subscribed.connect(on_subscribed)
	main.twitcher.cheered.connect(on_cheered)
	main.twitcher.connected_to_twitch.connect(add_commands)


func add_commands() -> void:
	main.twitcher.commands.add_command("laser", laser)
	main.twitcher.commands.add_command("zeroG", zero_g)
	main.twitcher.commands.add_alias("zeroG", "zerog")
	main.twitcher.commands.add_alias("zeroG", "0g")
	main.twitcher.commands.add_alias("zeroG", "0G")
	main.twitcher.commands.add_command("discord", discord)
	main.twitcher.commands.add_command("commands", chat_commands_help)
	log.i("Command added to the handler.")

func on_chat(_channel_name: String, _username: String, _message: String, _tags: TwitchTags.PrivMsg):
	if _username.to_lower() in ["pandacoder", "iraddev"]:
		if _message.find("https://") != -1 or _message.find("http://") != -1:
			var item_id = await main.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_VIDEOS, "Panda_no")
			print("Item Id: ", item_id)
			main.no_obs_ws.set_item_enabled(STREAM_OVERLAY_VIDEOS, item_id, false)
			await main.get_tree().process_frame
			main.no_obs_ws.set_item_enabled(STREAM_OVERLAY_VIDEOS, item_id, true)


func on_channel_points_redeemed(data : RSTwitchEventData):
	log.i("Channel points redeemed. %s -> %s" % [data.username, data.reward_title] )
	match data.reward_title:
		"beans": beans(data.username)
		"crt": start_screen_shader(RSShaders.FxType.CRT, 24.0)
		"speed": start_screen_shader(RSShaders.FxType.SPEED, 120.0)
		"old movie": start_screen_shader(RSShaders.FxType.OLD, 60.0)
		"open useless website": open_useless_website()
		"open browser history": open_browser_history()
		"Activate CoPilot for 5min": activate_copilot(300)
		"remove the cig break overlay": toggle_cig_overlay()
		"Give advice": main.vetting.custom_rewards_vetting(give_advice, data)
		"Get advice": get_advice(data)
		"Shut down stream": alert_on_stop_streaming(data.username)
		"Raid kani_dev": raid_kani(data.username)
		"Force raid a random streamer": raid_a_random_streamer_from_the_user_list()
		"Impersonate iRadDev": main.vetting.custom_rewards_vetting(impersonate_iRad, data)
		"Change Stream Title": main.vetting.custom_rewards_vetting(change_stream_title, data)
func on_followed(data : RSTwitchEventData):
	pass
func on_raided(data : RSTwitchEventData):
	pass
func on_subscribed(data : RSTwitchEventData):
	pass
func on_cheered(data : RSTwitchEventData):
	pass


func impersonate_iRad(data : RSTwitchEventData):
	var channel = data.user_input.split(" ", false, 1)[0].to_lower()
	#var msg = data.username + " wants me to tell you: "
	#msg += data.user_input.split(" ", false, 1)[1]
	var msg = data.user_input.split(" ", false, 1)[1]
	main.twitcher.irc.chat(msg, channel)

func give_advice(data : RSTwitchEventData) -> void:
	var folder_path = main.loader.get_config_path()
	var advice_file = folder_path + "advice_collection.json"
	var advice_list : Array = []
	check_if_advice_file_exists(advice_file)
	advice_list = main.loader.load_json(advice_file)
	var new_advice = {
		"adviser" : data.display_name,
		"advice" : data.user_input,
	}
	advice_list.append(new_advice)
	main.loader.save_to_json(advice_file, advice_list)

func check_if_advice_file_exists(advice_file : String):
	if not FileAccess.file_exists(advice_file):
		var advice_list = [
				{
					"adviser" : "iRadDev",
					"advice" : "We don't have enough beans! MORE BEANS!"
				},
				{
					"adviser" : "robmblind",
					"advice" : "If you want to go fast, go alone. If you want to go far, go together."
				},
			]
		main.loader.save_to_json(advice_file, advice_list)

func get_advice(data : RSTwitchEventData) -> void:
	var folder_path = main.loader.get_config_path()
	var advice_file = folder_path + "advice_collection.json"
	var advice_list : Array
	check_if_advice_file_exists(advice_file)
	advice_list = main.loader.load_json(advice_file)
	
	var advice = advice_list.pick_random()
	
	var advice_dic = {
		"user" : data.display_name,
		"adviser" : advice.adviser,
		"advice" : advice.advice,
	}
	var format_string : String = [
		'{user} you know what {adviser} said once? "{advice}"',
		'{user} you should listen to {adviser}: "{advice}"',
		'What {adviser} said to {user} resonated with him/her/they: "{advice}"',
		'{user} was reluctant to learn from {adviser}, but now he enjoys it: "{advice}"',
		'{user} attentively listen to {adviser}: "{advice}"',
		].pick_random()
	
	main.twitcher.chat(format_string.format(advice_dic) )


func discord(_info : TwitchCommandInfo = null, _args := []):
	var msg = "Join Discord: https://discord.gg/4YhKaHkcMb"
	main.twitcher.chat(msg)

func chat_commands_help(_info : TwitchCommandInfo = null, _args := []):
	var msg = "Use a combination of ![command] for chat: hl (highlight), hd(hidden), rb(rainbow), big, small, wave, pulse, tornado, shake"
	main.twitcher.chat(msg)

func add_physic_scene():
	if not physic_scene:
		physic_scene = RSGlobals.physic_scene_pack.instantiate()
		EditorInterface.get_base_control().add_child(physic_scene)
		physic_scene.main = main
		physic_scene.start()


func beans(username : String):
	add_physic_scene()
	if physic_scene.is_closing: return
	
	var beans_param := RSBeansParam.from_json(RSGlobals.params_can)
	var user := main.get_known_user(username.to_lower()) as RSTwitchUser
	if user:
		if user.custom_beans_params:
			beans_param = user.custom_beans_params
	physic_scene.add_image_bodies(beans_param)


func zero_g(_info : TwitchCommandInfo = null, _args := []):
	if not physic_scene:
		main.twitcher.chat("Wait for the physic scene to be in first!")
		return
	# main.twitcher.chat("%s initiated zero_g"%cmd_info.sender_data.user)
	#physic_scene.shake_bodies()
	var tw = main.create_tween()
	tw.tween_method(physic_scene.set_space_gravity, 4410, 0, 2.0)
	tw.tween_callback(physic_scene.shake_bodies)
	tw.tween_callback(physic_scene.shake_bodies).set_delay(10.0)
	tw.tween_method(physic_scene.set_space_gravity, 0, 4410, 5.0)


func laser(_info : TwitchCommandInfo = null, _args := []):
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
	var item_id = await main.no_obs_ws.get_scene_item_id(STREAM_OVERLAY_SCENE, "BRB_text")
	var scene_item_enabled = await main.no_obs_ws.get_item_enabled(STREAM_OVERLAY_SCENE, item_id)
	main.no_obs_ws.set_item_enabled(STREAM_OVERLAY_SCENE, item_id, !scene_item_enabled)



func alert_on_stop_streaming(username):
	if not alert_scene:
		alert_scene = RSGlobals.alert_scene_pack.instantiate()
		EditorInterface.get_base_control().add_child(alert_scene)
		alert_scene.main = main
		alert_scene.start()
		alert_scene.initialize_stop_streaming(username)


func stop_streaming():
	main.no_obs_ws.stop_stream()


func raid_kani(username : String):
	var kani_rs_user := main.get_known_user("kani_dev")
	alert_scene = RSGlobals.alert_scene_pack.instantiate()
	EditorInterface.get_base_control().add_child(alert_scene)
	alert_scene.main = main
	alert_scene.start()
	alert_scene.initialize_raid(username, kani_rs_user)


func raid_a_random_streamer_from_the_user_list():
	var streamers_live_data = await main.twitcher.get_live_streamers_data()
	if not wheel_of_random:
		wheel_of_random = RSGlobals.wheel_of_random_pack.instantiate()
		EditorInterface.get_base_control().add_child(wheel_of_random)
		wheel_of_random.main = main
		wheel_of_random.streamers_live_data = streamers_live_data
		wheel_of_random.start()
		wheel_of_random.spin_for_streamers()


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


func change_stream_title(data : RSTwitchEventData):
	var title = "%s - %s"%[data.user_input, data.username]
	var path = "/helix/channels?"
	path += "broadcaster_id=" + str(RSSettings.broadcaster_id) + "&"
	var res := await main.twitcher.api.request(path, HTTPClient.METHOD_PATCH, {"title":title}, "application/json")


func iRad_follow_somebody(data : RSTwitchEventData):
	pass
	# main.twitcher.api.get_followed_channels(
	
