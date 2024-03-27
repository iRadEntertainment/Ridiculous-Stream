@tool
extends PanelContainer

var main : RSMain

@onready var ln_broadcaster_id : LineEdit = %ln_broadcaster_id


func start():
	visible = !main.twitcher.is_connected_to_twitch
	if !main.twitcher.connected_to_twitch.is_connected(hide):
		main.twitcher.connected_to_twitch.connect(hide)
	ln_broadcaster_id.text = str(main.settings.broadcaster_id)

	# visible = !main.gift.is_connected_to_twitch
	# %ln_channel_name.text = main.settings.channel_name
	# %ln_bot_name.text = main.settings.bot_name

func _on_btn_connect_twitcher_pressed():
	# main.settings.channel_name = %ln_channel_name.text
	# main.settings.bot_name = %ln_bot_name.text
	main.twitcher.connect_to_twitch()
func _on_ln_broadcaster_id_text_submitted(new_text:String):
	TwitchSetting.broadcaster_id = new_text
	main.settings.broadcaster_id = int(new_text)
	main.save_rs_settings()
	_on_btn_connect_twitcher_pressed()
func _on_btn_retrieve_id_pressed():
	OS.shell_open("https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/")



