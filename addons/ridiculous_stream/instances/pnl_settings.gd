@tool
extends PanelContainer
class_name RSPnlSettings

@onready var side_vb = %side_vb
@onready var tabs = %tabs
@onready var side_bar = %side_bar

var main : RSMain


func start():
	reload_panels()
	connect_tab_buttons_to_tab_container()
	call_deferred("update_sidebar_pos")
	resized.connect(update_sidebar_pos)
	#about_to_popup.connect(reload_panels)
	%pnl_twitch_user_list.user_selected.connect(%pnl_twitch_user_fields.populate_fields)
	#%pnl_twitch_user_fields.new_user_file.connect(populate)


func populate():
	await %pnl_twitch_user_list.populate_user_button_list()


func reload_panels():
	for pnl in [%pnl_rs_settings, %pnl_test, %pnl_twitch_user_list, %pnl_twitch_user_fields, %pnl_rewards]:
		if pnl is PanelContainer:
			pnl.main = main
			if pnl.has_method("start"):
				pnl.start()


func connect_tab_buttons_to_tab_container():
	for i in side_vb.get_child_count():
		var btn := side_vb.get_child(i) as Button
		btn.pressed.connect(open_tab.bind(i))
func open_tab(index : int) -> void:
	for btn : Button in side_vb.get_children():
		btn.button_pressed = btn.get_index() == index
	index = min(index, tabs.get_child_count()-1)
	tabs.current_tab = index
	update_sidebar_pos()


func update_sidebar_pos():
	var btn_num = side_vb.get_child_count()
	var idx = tabs.current_tab
	var rect : Rect2 = side_vb.get_rect()
	rect.size.x = 4
	rect.size.y /= btn_num
	side_bar.position.x = -4
	side_bar.position.y = rect.size.y * idx
	side_bar.size = rect.size


func _on_btn_hot_reload_plugin_pressed():
	main.reload_plugin()
func _on_btn_hot_reload_pressed():
	main.call_deferred("hot_reload_pnl_settings")
	queue_free()
func _on_btn_open_irad_twitch_pressed():
	OS.shell_open("https://twitch.tv/iraddev")
	main.twitcher.chat("Ridiculous Stream has been provided kindly by iRadDev: https://twitch.tv/iraddev")
func _on_btn_open_github_pressed():
	OS.shell_open("https://github.com/iRadEntertainment/Ridiculous-Stream")
	main.twitcher.chat("Here is the repo for Ridiculous Stream, feel free to use, modify or contribute: https://github.com/iRadEntertainment/Ridiculous-Stream")
func _on_btn_credits_gift_pressed():
	main.twitcher.chat("Issork made Gift! That's what I am using: https://github.com/issork/gift")
func _on_btn_credits_twitcher_pressed():
	main.twitcher.chat("Kanimaru made Twitcher! https://github.com/kanimaru/twitcher")
func _on_btn_credits_noobs_pressed():
	main.twitcher.chat("Yagich made no-OBS-ws! https://github.com/Yagich/no-obs-ws")
func _on_btn_credits_polygon_pressed():
	main.twitcher.chat("SoloByte made Polygon2d fracture! https://github.com/SoloByte/godot-polygon2d-fracture")
