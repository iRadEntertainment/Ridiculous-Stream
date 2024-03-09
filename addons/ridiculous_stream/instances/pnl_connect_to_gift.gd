@tool
extends PanelContainer

var main : RSMain

func start():
	main.gift.connected_to_twitch.connect(hide)
	visible = !main.gift.is_connected_to_twitch
	%ln_channel_name.text = main.settings.channel
	%ln_bot_name.text = main.settings.bot_name


func _on_btn_connect_pressed():
	main.settings.channel = %ln_channel_name.text
	main.settings.bot_name = %ln_bot_name.text
	main.gift.start_connections()
func _on_ln_channel_name_text_changed(new_text):
	%ln_bot_name.text = new_text
func _on_ln_channel_name_text_submitted(new_text):
	_on_btn_connect_pressed()
