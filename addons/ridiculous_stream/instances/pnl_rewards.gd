@tool
extends PanelContainer

const reward_entry_pack = preload("res://addons/ridiculous_stream/instances/reward_entry.tscn")
@onready var list = %list

var main : RSMain

func start():
	pass

func update_list():
	for child in list.get_children():
		child.queue_free()
	
	var res := await main.twitcher.api.get_custom_reward([], false, str(main.settings.broadcaster_id))
	for reward : TwitchCustomReward in res.data:
		var entry = reward_entry_pack.instantiate()
		entry.reward = reward
		entry.main = main
		if reward.image:
			entry.icon_img = await main.loader.load_texture_from_url(reward.image.url_4x, false)
		list.add_child(entry)
		entry.owner = owner
		entry.start()


func _on_btn_update_pressed():
	update_list()


#func entry_from_data(redeem : TwitchCustomReward) -> HBoxContainer:
	#var entry := HBoxContainer.new()
	#var lb := Label.new()
	#lb.text = redeem.title
	#lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#var btn := CheckButton.new()
	#btn.button_pressed = redeem.is_enabled
	#entry.add_child(lb)
	#entry.add_child(btn)
	#return entry
