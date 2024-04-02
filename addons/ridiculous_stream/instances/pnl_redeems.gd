@tool
extends PanelContainer

var main : RSMain


func start():
	pass

func func_print_redeems():
	pass


func _on_btn_test_pressed():
	for child in %list.get_children():
		child.queue_free()
	
	var res := await main.twitcher.api.get_custom_reward([], false, str(main.settings.broadcaster_id))
	for redeem : TwitchCustomReward in res.data:
		var entry = entry_from_data(redeem)
		%list.add_child(entry)
		entry.owner = owner
		print(redeem.title, "is enabled: ", redeem.is_enabled)

func entry_from_data(redeem : TwitchCustomReward) -> HBoxContainer:
	var entry := HBoxContainer.new()
	var lb := Label.new()
	lb.text = redeem.title
	lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var btn := CheckButton.new()
	btn.button_pressed = redeem.is_enabled
	entry.add_child(lb)
	entry.add_child(btn)
	return entry
