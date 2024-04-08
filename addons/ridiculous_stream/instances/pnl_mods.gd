@tool
extends PanelContainer

var main: RSMain

@onready var lb_mod_count = %lb_mod_count
@onready var lb_followers_count = %lb_followers_count
@onready var percentage = %percentage


func start():
	if not main.twitcher.connected_to_twitch.is_connected(update_mod_follower_ratio):
		main.twitcher.connected_to_twitch.connect(update_mod_follower_ratio)

func update_mod_follower_ratio():
	var followers_count : int = await main.twitcher.get_follower_count()
	var mods : Array[TwitchUserModerator] = await main.twitcher.get_moderators()
	var ratio : float = mods.size()/float(followers_count)
	lb_mod_count.text = str(mods.size())
	lb_followers_count.text = str(followers_count)
	percentage.text = "%2.2f%%" % [ratio * 100]

func _on_btn_update_mod_count_pressed():
	update_mod_follower_ratio()
