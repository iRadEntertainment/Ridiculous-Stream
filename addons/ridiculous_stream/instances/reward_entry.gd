@tool
extends PanelContainer

@onready var icon = %icon
@onready var title = %title
@onready var ck_is_active = %ck_is_active
@onready var ln_input = %ln_input
@onready var cost = %cost

var main : RSMain
var reward : TwitchCustomReward
var icon_img : Texture2D


func start():
	if not reward: return
	
	ln_input.visible = reward.is_user_input_required
	if icon_img:
		icon.texture = icon_img
	
	title.text = reward.title
	cost.text = str(reward.cost)
	ck_is_active.button_pressed = reward.is_enabled


func _on_ck_is_active_toggled(toggled_on):
	if toggled_on == reward.is_enabled: return
	reward.is_enabled = toggled_on
	var body := TwitchUpdateCustomRewardBody.from_json(reward.to_dict())
	body.is_enabled = reward.is_enabled
	main.twitcher.api.update_custom_reward(reward.id, body)

func _on_btn_icon_pressed():
	pass
	#main.twitcher.api


