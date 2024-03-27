@tool
extends PanelContainer

var main : RSMain


func start():
	pass

func _on_btn_reload_plugin_pressed():
	main.reload_plugin()

func _on_data_dir_pressed():
	OS.shell_open(main.loader.get_config_path())
func _on_btn_open_user_dir_pressed():
	OS.shell_open(OS.get_user_data_dir())
func _on_btn_reconnect_gift_signals_pressed():
	main.connect_gift_signals()
func _on_btn_reload_gift_pressed():
	main.call_deferred("reload_gift")

func _on_btn_reload_commands_pressed():
	main.add_commands()
func open_silent_newground_page():
	OS.shell_open("https://silentground.newgrounds.com/")
func _on_ck_co_pilot_toggled(toggled_on):
	pass
	#co_pilot = toggled_on
func _on_btn_silent_pressed():
	open_silent_newground_page()






