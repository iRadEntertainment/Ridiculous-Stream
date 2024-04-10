@tool
extends PanelContainer

var main : RSMain

@onready var ln_broadcaster_id : LineEdit = %ln_broadcaster_id
@onready var btn_connect_at_startup = %btn_connect_at_startup


func start():
	visible = !main.twitcher.is_connected_to_twitch
	if !main.twitcher.connected_to_twitch.is_connected(hide):
		main.twitcher.connected_to_twitch.connect(hide)
	ln_broadcaster_id.text = str(RSSettings.broadcaster_id)
	btn_connect_at_startup.button_pressed = RSSettings.auto_connect


func _on_btn_connect_twitcher_pressed():
	connect_to_twitch()

func _on_ln_broadcaster_id_text_submitted(_new_text:String):
	connect_to_twitch()

func _on_btn_retrieve_id_pressed():
	OS.shell_open("https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/")

func _on_btn_connect_at_startup_toggled(toggled_on:bool):
	if toggled_on != RSSettings.auto_connect:
		RSSettings.auto_connect = toggled_on

func connect_to_twitch():
	RSSettings.broadcaster_id = int(ln_broadcaster_id.text)
	TwitchSetting.broadcaster_id = ln_broadcaster_id.text
	main.save_rs_settings()
	main.twitcher.connect_to_twitch()
