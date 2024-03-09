@tool
extends Window

var main : RSMain


func start():
	reload_panels()
	#about_to_popup.connect(reload_panels)
	%pnl_twitch_user_list.user_selected.connect(%pnl_twitch_user_fields.populate_fields)
	#%pnl_twitch_user_fields.new_user_file.connect(populate)


func populate():
	await %pnl_twitch_user_list.populate_user_button_list()


func reload_panels():
	for pnl in [%pnl_rs_settings, %pnl_test, %pnl_twitch_user_list, %pnl_twitch_user_fields]:
		if pnl is PanelContainer:
			pnl.main = main
			if pnl.has_method("start"):
				pnl.start()


func _on_close_requested():
	hide()


func _on_btn_hot_reload_pressed():
	main.call_deferred("hot_reaload_wn_settings")
	queue_free()
func _on_btn_credits_pressed():
	main.gift.chat("Go figure! Issork made Gift! That's what I am using: https://github.com/issork/gift")
