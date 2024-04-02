@tool
extends HBoxContainer

var main : RSMain
var user : RSTwitchUser
var live_data : TwitchStream
var profile_pic : ImageTexture : set = set_profile_pic

@onready var user_pic = $user_pic
@onready var btn_user = $btn_user
@onready var btn_shoutout = $btn_shoutout
@onready var btn_promote = $btn_promote
@onready var btn_special = $btn_special
@onready var btn_reload = $btn_reload
@onready var user_live_rect = $btn_user/user_live_rect

signal user_selected(user, live_data)

func start():
	user_pic = $user_pic
	btn_user = $btn_user
	btn_shoutout = $btn_shoutout
	btn_promote = $btn_promote
	btn_special = $btn_special
	btn_reload = $btn_reload
	
	btn_user.text = user.display_name
	btn_shoutout.disabled = !user.is_streamer
	btn_promote.disabled = user.promotion_description == ""
	btn_special.disabled = user.custom_action == ""
	
	user_live_rect.visible = live_data != null


func reload_profile_pic():
	profile_pic = await main.loader.load_texture_from_url(user.profile_image_url)
	if not is_node_ready(): await ready
	if profile_pic: user_pic.texture = profile_pic
func set_profile_pic(val):
	profile_pic = val
	if not is_node_ready(): await ready
	if profile_pic: user_pic.texture = profile_pic

func _on_btn_user_pressed():
	user_selected.emit(user, live_data)
func _on_btn_shoutout_pressed():
	main.shoutout_mng.add_shoutout(user)
func _on_btn_promote_pressed():
	main.twitcher.chat(user.promotion_description)
func _on_btn_special_pressed():
	pass # Replace with function body.
func _on_btn_reload_pressed():
	reload_profile_pic()
