@tool
extends PanelContainer

var main : RSMain

func start():
	pass

func _on_data_dir_pressed():
	OS.shell_open(main.loader.get_config_path())
func _on_btn_open_user_dir_pressed():
	OS.shell_open(OS.get_user_data_dir())

func _on_btn_reload_twitcher_pressed():
	main.call_deferred("reload_twitcher")
func _on_btn_reload_commands_pressed():
	main.custom.add_commands()

func _on_btn_open_cache_badges_dir_pressed():
	OS.shell_open(TwitchSetting.cache_badge)
func _on_btn_open_cache_emotes_dir_pressed():
	OS.shell_open(TwitchSetting.cache_emote)
func _on_btn_open_cache_cheer_emotes_dir_pressed():
	OS.shell_open(TwitchSetting.cache_cheermote)


func _on_btn_obs_connect_pressed():
	main.no_obs_ws.connect_to_obsws(int(RSSettings.obs_websocket_port), RSSettings.obs_websocket_password)


func _on_btn_obs_req_api_pressed() -> void:
	OS.shell_open("https://github.com/obsproject/obs-websocket/blob/master/docs/generated/protocol.md#requests")
