@tool
extends Resource
class_name RSExternalLoader

var cached = {}
var main : RSMain

func load_settings() -> void:
	var path = get_config_path() + RSGlobals.rs_settings_file_name
	if FileAccess.file_exists(path):
		var json = load_json(path)
		RSSettings.from_json(json)
func save_settings() -> void:
	var path = get_config_path() + RSGlobals.rs_settings_file_name
	save_to_json(path, RSSettings.to_dict())


func save_to_json(file_path: String, variant: Variant) -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(variant, "\t"))
	file.close()
func load_json(file_path: String) -> Variant:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)


func convert_all_users():
	var dic = {}
	var user_files = list_file_in_folder(get_users_path(), ["tres"])
	
	for user_file in user_files:
		var path = get_users_path() + user_file
		var username = username_from_userfile(user_file)
		var res = await ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RSTwitchUser
		if res.username:
			pass
			# print("user loaded OK: ", res.username)
		else:
			print("user missing info: ", username)
		dic[username] = {"RSTwitchUser": res, "path": path}

	for username in dic.keys():
		var res := dic[username]["RSTwitchUser"] as RSTwitchUser
		var path := dic[username]["path"] as String
		path = path.trim_suffix("tres") + "json"
		save_to_json(path, res.to_dict())
		

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

#=========================================== USERSERSRESWRES ========================================================
func load_userfile(username) -> RSTwitchUser:
	var path := get_user_filepath(username)
	if !FileAccess.file_exists(path):
		print("Cannot find file: ", path)
	var user := RSTwitchUser.from_json(load_json(path))
	if user.username == "":
		user.username = username_from_userfile(path)
		print("WARNING: %s doesn't contain a username."%path.get_file())
	return user
func save_userfile(user : RSTwitchUser) -> void:
	if user.username == "":
		print("cannot save an user without a username")
		return
	var path = get_user_filepath(user.username)
	var dict = user.to_dict()
	if not dict.is_empty():
		save_to_json(path, dict)


func load_all_user() -> Dictionary:
	var dic = {}
	var user_files = list_file_in_folder(get_users_path(), ["json"])
	
	for user_file in user_files:
		var username = username_from_userfile(user_file)
		var res = load_userfile(username)
		dic[username] = res
	
	return dic
func save_all_user(dic):
	for username in dic:
		var user := dic[username] as RSTwitchUser
		save_userfile(user)


func userfile_from_username(username : String) -> String:
	return "user_%s.json" % username
func username_from_userfile(userfile : String) -> String:
	userfile = userfile.get_file()
	return userfile.trim_prefix("user_").trim_suffix(".json")
func get_user_filepath(username : String) -> String:
	var user_file = "user_%s.json" % username
	return get_users_path() + user_file
#=========================================== USERSERSRESWRES ========================================================


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










