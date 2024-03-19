@tool
extends Resource
class_name RSExternalLoader


var cached = {}
var main : RSMain

func load_settings() -> RSSettings:
	var path = get_config_path() + RSGlobals.rs_settings_file_name
	var settings : RSSettings
	if FileAccess.file_exists(path):
		settings = ResourceLoader.load(path, "RSSettings", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		settings = RSSettings.new()
	return settings
func save_settings(settings : RSSettings):
	var path = get_config_path() + RSGlobals.rs_settings_file_name
	ResourceSaver.save(settings, path)


#func load_rigid_body_instance_from_obj_folder(rigid_body_scn_name : String) -> RigidBody2D:
	#if rigid_body_scn_name in cached.keys():
		#return cached[rigid_body_scn_name]
	#var obj_global_path = get_obj_path()
	##print(obj_global_path)
	#var filename = rigid_body_scn_name+".tscn"
	#var filescript = rigid_body_scn_name+".gd"
	#var file_path = obj_global_path+filename
	#var file_script_path = obj_global_path+filescript
	#
	## TODO: search in the obj folder if cannot find the obj name in the external folder
	#
	#if !filename in list_file_in_folder(obj_global_path):
		#return null
	#if not FileAccess.file_exists(file_script_path):
		#print("RSExternalLoader: file %s doesn't have a correspondent %s" % [filename, filescript])
		#return null
	#
	#var body_pack = ResourceLoader.load(obj_global_path+filename, "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	#var body = body_pack.instantiate()
	#body.set_script(ResourceLoader.load(file_script_path, "GDScript", ResourceLoader.CACHE_MODE_IGNORE))
	#cached[rigid_body_scn_name] = body
	#return body


func load_sfx_from_sfx_folder(sfx_name : String) -> AudioStreamOggVorbis:
	if sfx_name in cached.keys():
		return cached[sfx_name]
	var audio : AudioStream
	if sfx_name in list_file_in_folder(RSGlobals.local_res_folder):
		audio = ResourceLoader.load(RSGlobals.local_res_folder+sfx_name)
	else:
		var sfx_global_path = get_sfx_path()
		audio = AudioStreamOggVorbis.load_from_file(sfx_global_path+sfx_name)
	cached[sfx_name] = audio
	return audio


func load_texture_from_url(url : String, use_cached := true) -> ImageTexture:
	if url in cached.keys() and use_cached:
		return cached[url]
	var file_type = url.get_extension()
	if not file_type in ["png", "jpeg", "jpg", "bmp", "webp", "svg"]: return
	if main.http_request.is_processing():
		await main.http_request.request_completed
	main.http_request.request(url)
	var data = await main.http_request.request_completed
	var image_buffer = data[3]
	var tex_image := Image.new()
	match file_type:
		"png": tex_image.load_png_from_buffer(image_buffer)
		"jpeg", "jpg": tex_image.load_jpg_from_buffer(image_buffer)
		"bmp": tex_image.load_bmp_from_buffer(image_buffer)
		"webp": tex_image.load_webp_from_buffer(image_buffer)
		"svg": tex_image.load_svg_from_buffer(image_buffer)
		_:
			push_error("RSExternalLoader: %s format not recognised."%file_type)
			return
	
	var tex = ImageTexture.create_from_image(tex_image)
	cached[url] = tex
	return tex


func load_texture_from_data_folder(texture_file_name : String) -> Texture2D:
	if texture_file_name in cached.keys():
		return cached[texture_file_name]
	var tex
	if texture_file_name in list_file_in_folder(RSGlobals.local_res_folder):
		tex = ResourceLoader.load(RSGlobals.local_res_folder+texture_file_name)
		
	else:
		var tex_path = get_obj_path()+texture_file_name
		var tex_image = Image.load_from_file(tex_path)
		tex = ImageTexture.create_from_image(tex_image)
	cached[texture_file_name] = tex
	return tex


func load_all_user() -> Dictionary:
	var dic = {}
	var user_files = list_file_in_folder(get_users_path(), ["tres"])
	
	for user_file in user_files:
		var path = get_users_path() + user_file
		var res = await ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RSTwitchUser
		var username = res.username
		dic[username] = res
	
	return dic
func save_all_user(dic):
	for username in dic:
		var user := dic[username] as RSTwitchUser
		save_userfile(user)


func userfile_from_username(username : String) -> String:
	return "user_%s.tres" % username
func username_from_userfile(userfile : String) -> String:
	return userfile.trim_prefix("user_").trim_suffix(".tres")
func get_user_filepath(username : String) -> String:
	var user_file = "user_%s.tres" % username
	return get_users_path() + user_file


func load_userfile(username) -> RSTwitchUser:
	var path = get_user_filepath(username)
	if !FileAccess.file_exists(path):
		print_stack()
	var user : RSTwitchUser = await ResourceLoader.load(path, "RSTwitchUser", ResourceLoader.CACHE_MODE_IGNORE)
	return user
func save_userfile(user : RSTwitchUser):
	var path = get_user_filepath(user.username)
	ResourceSaver.save(user, path)


#region UTILITIES
static func make_path(path):
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)

static func get_config_path() -> String:
	var path := "%s/%s"%[OS.get_data_dir(),
		RSGlobals.rs_config_folder]
	make_path(path)
	return path
static func get_users_path() -> String:
	var path := "%s%s"%[get_config_path(),
		RSGlobals.rs_user_folder]
	make_path(path)
	return path
static func get_obj_path() -> String:
	var path := "%s%s"%[get_config_path(),
		RSGlobals.rs_obj_folder]
	make_path(path)
	return path
static func get_sfx_path() -> String:
	var path := "%s%s"%[get_config_path(),
		RSGlobals.rs_sfx_folder]
	make_path(path)
	return path
static func get_logs_path() -> String:
	var path := "%s%s"%[get_config_path(),
		RSGlobals.rs_log_folder]
	make_path(path)
	return path


static func fix_external_res(file_path : String, from : String, to : String):
	if !FileAccess.file_exists(file_path):
		push_error("%s is not a valid file_path"%file_path)
		return
	var file := FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.store_string(file.get_as_text().replace(from, to))
	file.close()


static func list_file_in_folder(folder_path : String, types : Array = [], full_path := false) -> PackedStringArray:
	var found_files : PackedStringArray = []
	
	if !folder_path.ends_with("/"):
		folder_path += "/"
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				if file_name.get_extension() in types or types.is_empty():
					if not full_path:
						found_files.append(file_name)
					else:
						found_files.append(folder_path + file_name)
					#print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return found_files


static func opt_btn_from_files_in_folder(folder_paths : Array[String], types : Array[String] = [], full_path := false) -> OptionButton:
	var new_opt_btn := OptionButton.new()
	populate_opt_btn_from_files_in_folder(new_opt_btn, folder_paths, types, full_path)
	return new_opt_btn


static func populate_opt_btn_from_files_in_folder(opt_btn : OptionButton, folder_paths : Array[String], types : Array[String] = [], full_path := false):
	opt_btn.clear()
	opt_btn.add_item("", 0)
	opt_btn.add_separator("External Resources")
	for i in folder_paths.size():
		var folder = folder_paths[i]
		var list_of_files = RSExternalLoader.list_file_in_folder(folder, types, full_path)
		for file in list_of_files:
			opt_btn.add_item(file, opt_btn.item_count+1)
		if i < folder_paths.size()-1:
			opt_btn.add_separator("Local Resources")



#endregion










