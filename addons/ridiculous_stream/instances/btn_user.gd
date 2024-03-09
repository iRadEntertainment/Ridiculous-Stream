@tool
extends HBoxContainer

var main : RSMain
var user : RSTwitchUser
var profile_pic : ImageTexture : set = set_profile_pic
var is_live := false : set = set_is_live


signal user_selected(user)

func start():
	$btn_user.text = user.display_name
	$btn_shoutout.disabled = !user.is_streamer
	$btn_promote.disabled = user.promotion_description == ""
	$btn_special.disabled = user.custom_action == ""


func reload_profile_pic():
	profile_pic = await main.loader.load_texture_from_url(user.profile_image_url)
	if profile_pic: $user_pic.texture = profile_pic
func set_profile_pic(val):
	profile_pic = val
	if profile_pic: $user_pic.texture = profile_pic

func _on_btn_user_pressed():
	user_selected.emit(user)
func _on_btn_shoutout_pressed():
	main.shoutout_mng.add_shoutout(user)
func _on_btn_promote_pressed():
	main.gift.chat(user.promotion_description)
func _on_btn_special_pressed():
	pass # Replace with function body.
func _on_btn_reload_pressed():
	reload_profile_pic()

func set_is_live(val):
	is_live = val
	%led.visible = val
	if is_live:
		%tmr_led.start()
func _on_tmr_led_timeout():
	#is_live = false
	%led.visible = false











