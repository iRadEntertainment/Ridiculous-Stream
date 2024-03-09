@tool
extends PanelContainer

var main : RSMain
var gl_user : RSTwitchUser

func start():
	update_dropdown_fields()
	%pnl_connect_to_gift.main = main
	%pnl_connect_to_gift.start()


func populate_fields(user : RSTwitchUser):
	gl_user = user
	%tex_profile_pic.texture = await main.loader.load_texture_from_url(user.profile_image_url)
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url
	%cr_user_twitch_irc_color.color = user.twitch_chat_color
	
	%fl_is_streamer.button_pressed = user.is_streamer
	%fl_auto_shoutout.button_pressed = user.auto_shoutout
	%fl_auto_promotion.button_pressed = user.auto_promotion
	
	%btn_custom_color.color = user.custom_chat_color
	opt_btn_select_from_text(%opt_custom_sfx, user.custom_notification_sfx)
	opt_btn_select_from_text(%opt_custom_actions, user.custom_action)
	
	check_param_and_add_inspector(user.custom_beans_params)
	#clear_param_inspector()
	if user.custom_beans_params != {}:
		%btn_add_custom_beans.button_pressed = true
		
	
	%te_so.text = user.shoutout_description
	%te_promote.text = user.promotion_description

func check_param_and_add_inspector(params):
	clear_param_inspector()
	%btn_add_custom_beans.button_pressed = false
	if params == null: return
	if params != {}:
		var param_inspector = RSGlobals.param_inspector_pack.instantiate()
		%sub_res.add_child(param_inspector)
		param_inspector.owner = owner
		param_inspector.params = params
		btn_custom_beans_is_gui_input = false
		%btn_add_custom_beans.button_pressed = true
func clear_param_inspector():
	#%btn_add_custom_beans.button_pressed = false
	for child in %sub_res.get_children():
		child.queue_free()


func user_from_fields() -> RSTwitchUser:
	var user := RSTwitchUser.new()
	user.username = %ln_username.text
	user.display_name = %ln_display_name.text
	user.user_id = %ln_user_id.text as int
	user.profile_image_url = %ln_profile_picture_url.text
	
	user.is_streamer = %fl_is_streamer.button_pressed
	user.auto_shoutout = %fl_auto_shoutout.button_pressed
	user.auto_promotion = %fl_auto_promotion.button_pressed
	
	user.custom_chat_color = %btn_custom_color.color
	user.custom_notification_sfx = %opt_custom_sfx.get_item_text(%opt_custom_sfx.selected)
	user.custom_action = %opt_custom_actions.get_item_text(%opt_custom_actions.selected)
	#-----------------------------
	user.custom_beans_params = {}
	if %btn_add_custom_beans.button_pressed:
		var param_inspector : RSParamInspector = %sub_res.get_child(0)
		user.custom_beans_params = param_inspector.get_params()
	
	user.shoutout_description = %te_so.text
	user.promotion_description = %te_promote.text
	return user


func clear_custom_fields():
	%fl_is_streamer.button_pressed = false
	%fl_auto_shoutout.button_pressed = false
	%fl_auto_promotion.button_pressed = false
	%btn_custom_color.color = Color()
	%opt_custom_sfx.selected = 0
	%opt_custom_beans.selected = 0
	%opt_custom_actions.selected = 0
	%te_so.text = ""
	%te_promote.text = ""


func update_user():
	var user = user_from_fields()
	await main.loader.save_userfile(user)
	await main.load_known_user(user.username)
	#new_user_file.emit()

func search_user(username : String):
	pass


func gather_username_info_from_api():
	var possible_username = %ln_search.text
	if possible_username in main.globals.known_users.keys():
		populate_fields(main.globals.known_users[possible_username])
	else:
		clear_custom_fields()
	var user = await main.gift.gather_user_info(possible_username)
	if !user: return
	%tex_profile_pic.texture = await main.loader.load_texture_from_url(user.profile_image_url)
	%ln_username.text = user.username
	%ln_display_name.text = user.display_name
	%ln_user_id.text = str(user.user_id)
	%ln_profile_picture_url.text = user.profile_image_url


func update_dropdown_fields():
	var sfx_paths : Array[String] = [RSExternalLoader.get_sfx_path(), RSGlobals.local_res_folder]
	RSExternalLoader.populate_opt_btn_from_files_in_folder(%opt_custom_sfx, sfx_paths, ["ogg"])
	
	var custom_script = ResourceLoader.load("res://addons/ridiculous_stream/RSCustom.gd", "GDScript", ResourceLoader.CACHE_MODE_IGNORE) as GDScript
	var functions_dics = custom_script.get_script_method_list()
	var functions = []
	var exclude = ["start", "discord"]
	for f_dic in functions_dics:
		if f_dic.name in exclude: continue
		if f_dic.name.begins_with("on_"): continue
		functions.append(f_dic.name)
	opt_btn_populate_from_list(%opt_custom_actions, functions)


func opt_btn_populate_from_list(opt_button : OptionButton, list : Array, add_empty := true):
	opt_button.clear()
	if add_empty:
		opt_button.add_item("", 0)
	for i in list.size():
		var file_name = list[i]
		opt_button.add_item(file_name, i+1)


func opt_btn_select_from_text(opt_button : OptionButton, text : String):
	for i in opt_button.item_count:
		if opt_button.get_item_text(i) == text:
			opt_button.select(i)
			break


func _on_ln_search_text_submitted(new_text):
	gather_username_info_from_api()
func _on_opt_custom_sfx_item_selected(index):
	%sfx_prev.stop()
	var sfx_name = %opt_custom_sfx.get_item_text(index)
	%sfx_prev.stream = main.loader.load_sfx_from_sfx_folder(sfx_name)
	%sfx_prev.play()
func _on_btn_save_pressed():
	update_user()
func _on_btn_open_file_pressed():
	OS.shell_open(main.loader.get_user_filepath(%ln_username.text))
func _on_btn_open_folder_pressed():
	OS.shell_open(main.loader.get_users_path())


# ==============================================================================
#func set_do_it(val):
	#do_it = val
	#return
	##add_res_picker($scroll/vb/grid_custom/dummy1, "ImageToRigidParam")
	#add_editor_inspector(%inspector)
#
#
#func add_res_picker(node_to_replace: Control, resource_type := ""):
	#var to_node = node_to_replace.get_parent()
	#var replace_pos = node_to_replace.get_index()
	#node_to_replace.queue_free()
	#
	#var res_picker = EditorResourcePicker.new()
	#res_picker.base_type = resource_type
	#res_picker.editable = true
	##res_picker.resource_selected.connect(EditorInterface.edit_resource.unbind(1))
	#to_node.add_child(res_picker)
	#to_node.move_child(res_picker, replace_pos)
	#res_picker.owner = self
#
#func add_editor_inspector(node_to_replace: Control):
	#var to_node = node_to_replace.get_parent()
	#var replace_pos = node_to_replace.get_index()
	#node_to_replace.queue_free()
	#
	#var ed_insp = EditorInterface.get_inspector().duplicate()
	#to_node.add_child(ed_insp)
	#to_node.move_child(ed_insp, replace_pos)
	#ed_insp.owner = self
#
#func _on_res_picker_resource_selected(resource, _inspect):
	##%res_insp.resource = resource
	##%inspector.edited_object == (resource)
	#EditorInterface.edit_resource(resource)
	##EditorInspector.edited_object()

func add_param_inspector():
	print("here")
	if %sub_res.get_child_count() > 0: return
	if gl_user.custom_beans_params != {}:
		check_param_and_add_inspector(gl_user.custom_beans_params)
	else:
		check_param_and_add_inspector(RSGlobals.params_can)
	#var param_inspector : RSParamInspector = RSGlobals.param_inspector_pack.instantiate()
	#%sub_res.add_child(param_inspector)
	#param_inspector.owner = owner
	#param_inspector.params = RSGlobals.params_can

var btn_custom_beans_is_gui_input := true
func _on_btn_add_custom_beans_toggled(toggled_on):
	%sub_res.visible = toggled_on
	if not btn_custom_beans_is_gui_input:
		btn_custom_beans_is_gui_input = true
		return
	if toggled_on:
		add_param_inspector()
	else:
		clear_param_inspector()





func _on_btn_test_beans_pressed():
	var user := user_from_fields()
	if !user.username.is_empty():
		main.custom.beans(user.username)
