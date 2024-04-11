@tool
extends PanelContainer

@onready var userlist = %userlist
@onready var infolist = %infolist
@onready var warn_count = %warn_count

var main : RSMain

var selected_user : String

func start():
	if !main.vetting.list_updated.is_connected(populate_list):
		main.vetting.list_updated.connect(populate_list)
	populate_list()


func populate_list():
	for child in userlist.get_children():
		child.queue_free()
	
	for user in main.vetting.user_vetting_list.keys():
		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.custom_minimum_size.y = 32
		btn.text = user
		btn.pressed.connect(populate_vetting_info.bind(user))
		userlist.add_child(btn)

func populate_vetting_info(user: String):
	selected_user = user
	
	var warnings : int = main.vetting.user_vetting_list[user]["warnings"]
	warn_count.value = warnings
	
	for child in infolist.get_children():
		child.queue_free()
	
	var rewards = main.vetting.user_vetting_list[user]["rewards"]
	for title in rewards.keys():
		var status = rewards[title]
		var lb = Label.new()
		lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lb.text = title
		lb.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		infolist.add_child(lb)
		
		var opt = OptionButton.new()
		opt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for i in RSVetting.Responses.size():
			var key = RSVetting.Responses.keys()[i]
			opt.add_item(key, i)
		
		opt.select(status)
		infolist.add_child(opt)


func _on_btn_reload_pressed():
	populate_list()
