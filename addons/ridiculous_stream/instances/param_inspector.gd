@tool
extends PanelContainer
class_name RSParamInspector

var params : RSBeansParam : set = set_params


func populate_fields():
	clear_custom_lists()
	for tex_path in params.img_paths:
		var opt_btn := new_tex_opt_btn()
		%tex_list.add_child(opt_btn)
		set_item_opt_btn_from_string(opt_btn, tex_path)
	
	for sfx_path in params.sfx_paths:
		var opt_btn := new_sfx_opt_btn()
		%sfx_list.add_child(opt_btn)
		set_item_opt_btn_from_string(opt_btn, sfx_path)
	
	%sl_sfx_vol.value = params.sfx_volume
	%sfx_vol_val.text = "%.01f"%(params.sfx_volume)
	
	%ck_is_pickable.button_pressed = params.is_pickable
	%ck_is_destroy.button_pressed = params.is_destroy
	%ck_is_fracture.button_pressed = params.is_poly_fracture
	
	%sb_scale_x.value = params.scale.x
	%sb_scale_y.value = params.scale.y
	
	%sb_spawn_min.value = params.spawn_range[0]
	%sb_spawn_max.value = params.spawn_range[1]
	%sb_coll_layer.value = params.coll_layer
	%sb_coll_mask.value = params.coll_mask
	
	for child in %sub_res.get_children():
		child.queue_free()
	if params.destroy_shard_params:
		var param_inspector : RSParamInspector = RSGlobals.param_inspector_pack.instantiate()
		%sub_res.add_child(param_inspector)
		param_inspector.owner = owner
		param_inspector.params = params.destroy_shard_params


func params_from_fields() -> RSBeansParam:
	var new_params = RSBeansParam.new()
	for opt_btn : OptionButton in %tex_list.get_children():
		var path = opt_btn.get_item_text(opt_btn.selected)
		if path.is_empty(): continue
		new_params.img_paths.append(path)
	for opt_btn : OptionButton in %sfx_list.get_children():
		var path = opt_btn.get_item_text(opt_btn.selected)
		if path.is_empty(): continue
		new_params.sfx_paths.append(path)

	new_params.sfx_volume = %sl_sfx_vol.value
	
	new_params.is_pickable = %ck_is_pickable.button_pressed
	new_params.is_destroy = %ck_is_destroy.button_pressed
	new_params.is_poly_fracture = %ck_is_fracture.button_pressed
	
	new_params.scale = Vector2(%sb_scale_x.value, %sb_scale_y.value)
	new_params.spawn_range = [%sb_spawn_min.value as int, %sb_spawn_max.value as int]
	new_params.coll_layer = %sb_coll_layer.value as int
	new_params.coll_mask = %sb_coll_mask.value as int
	
	if $vb/hb2/ck_shard.button_pressed:
		new_params.destroy_shard_params = %sub_res.get_child(0).get_params()
	
	return new_params

func _on_ck_shard_toggled(toggled_on):
	%sub_res.visible = toggled_on
	for child in %sub_res.get_children():
			child.queue_free()
	if toggled_on:
		var new_inspector = RSGlobals.param_inspector_pack.instantiate()
		%sub_res.add_child(new_inspector)
		new_inspector.owner = owner
		if params.destroy_shard_params:
			new_inspector.params = params.destroy_shard_params
		else:
			new_inspector.params = RSBeansParam.new()


func set_params(val : RSBeansParam):
	params = val
	populate_fields()
func get_params() -> RSBeansParam:
	return params_from_fields()


func clear_custom_lists():
	for child in %sfx_list.get_children() + %tex_list.get_children():
		child.queue_free()

func set_item_opt_btn_from_string(opt_btn : OptionButton, value : String):
	for i in opt_btn.item_count:
		if opt_btn.get_item_text(i) == value:
			opt_btn.selected = i
			break


func new_tex_opt_btn() -> OptionButton:
	var tex_folders : Array[String] = [RSExternalLoader.get_obj_path(), RSGlobals.local_res_folder]
	return RSExternalLoader.opt_btn_from_files_in_folder(tex_folders, ["png", "jpg", "jpeg", "btm"])
func new_sfx_opt_btn() -> OptionButton:
	var sfx_folders : Array[String] = [RSExternalLoader.get_sfx_path(), RSGlobals.local_res_folder]
	return RSExternalLoader.opt_btn_from_files_in_folder(sfx_folders, ["ogg"])

func _on_btn_add_tex_pressed():
	var btn_opt := new_tex_opt_btn()
	%tex_list.add_child(btn_opt)
	btn_opt.owner = owner
func _on_btn_remove_tex_pressed():
	if %tex_list.get_child_count() > 0:
		%tex_list.get_child(%tex_list.get_child_count()-1).queue_free()

func _on_btn_add_sfx_pressed():
	var btn_opt := new_sfx_opt_btn()
	%sfx_list.add_child(btn_opt)
	btn_opt.owner = owner
func _on_btn_remove_sfx_pressed():
	if %sfx_list.get_child_count() > 0:
		%sfx_list.get_child(%sfx_list.get_child_count()-1).queue_free()
func _on_sl_sfx_vol_value_changed(value):
	%sfx_vol_val.text = "%2.1f"%value















