# ================== #
#      RSMain.gd     #
# ================== #

@tool
extends EditorPlugin
class_name RSMain

var settings : RSSettings

var globals := RSGlobals.new()
var loader := RSExternalLoader.new()
var http_request := HTTPRequest.new()

var dock : RSDock
var gift : RSGift
var twitcher : RSTwitcher
var no_obs_ws : NoOBSWS

var shoutout_mng : RSShoutoutMng
var physics_space_rid : RID #TODO: remove?
var custom : RSCustom
var copilot : RSCoPilot
var wn_settings : Window

# ================================ INIT ========================================
func _enter_tree() -> void:
	print("=================================== RIDICULOS STREAMING STARTED ===================================")
	load_rs_settings()
	load_known_user()
	reload_twitcher()
	add_tool_generate_rest_api()
	add_nodes()
	reload_dock()


func reload_twitcher():
	if !twitcher:
		twitcher = RSTwitcher.new()
		add_child(twitcher)
	twitcher.main = self
	twitcher.start()

func add_tool_generate_rest_api():
	if not twitcher: return
	add_tool_menu_item("Regenerate Twitch REST Api", twitcher.generator.generate_rest_api)

func add_nodes():
	# --- resources
	custom = RSCustom.new()
	custom.main = self
	custom.start()
	loader.main = self
	# --- tree nodes
	shoutout_mng = RSShoutoutMng.new()
	shoutout_mng.main = self
	add_child(shoutout_mng)
	shoutout_mng.start()
	add_child(http_request)
	copilot = RSCoPilot.new()
	copilot.main = self
	add_child(copilot)
	copilot.start()
	no_obs_ws = NoOBSWS.new()
	add_child(no_obs_ws)
	no_obs_ws.connect_to_obsws(4455, settings.obs_websocket_password)
	hot_reaload_wn_settings()

func hot_reaload_wn_settings():
	wn_settings = RSGlobals.wn_settings_pack.instantiate()
	wn_settings.visible = false
	wn_settings.main = self
	EditorInterface.get_base_control().add_child(wn_settings)
	wn_settings.start()



# ================================ DOCK ========================================
func reload_dock():
	if dock:
		remove_control_from_docks(dock)
		dock.free()
	dock = RSGlobals.dock_pack.instantiate()
	dock.main = self
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	var dock_cont := dock.get_parent() as TabContainer
	dock_cont.move_child(dock, 1)
	dock_cont.current_tab = 1
	#if gift:
		#dock.start()
	if twitcher:
		dock.start()


# ================================ GIFT ========================================
func reload_gift():
	if !gift:
		gift = RSGift.new()
		add_child(gift)
	gift.main = self
	gift.start()
	gift_reloaded.emit()


# =============================== KNOWN USERS ==================================
func load_known_user(username := ""):
	if username.is_empty():
		globals.known_users = await loader.load_all_user()
	else:
		globals.known_users[username] = await loader.load_userfile(username)
func save_known_users():
	loader.save_all_user(globals.known_users)
func get_known_user(username : String) -> RSTwitchUser:
	var user = null
	if username in globals.known_users.keys():
		user = globals.known_users[username]
	return user


# ========================== LOAD/SAVE CONFIG ==================================
func load_rs_settings():
	print("Loading settings from RSMain")
	settings = loader.load_settings()
func save_rs_settings():
	print("Saving settings from RSMain")
	settings.client_id = ProjectSettings.get_setting("twitch/auth/client_id")
	settings.client_secret = ProjectSettings.get_setting("twitch/auth/client_secret")
	settings.authorization_flow = ProjectSettings.get_setting("twitch/auth/authorization_flow")
	settings.broadcaster_id = ProjectSettings.get_setting("twitch/auth/broadcaster_id")
	loader.save_settings(settings)


# =============================== UTILS =======================================
func get_current_code_edit() -> CodeEdit:
	var editor_script := EditorInterface.get_script_editor().get_current_editor()
	return editor_script.get_base_editor() as CodeEdit
func get_2d_main_screen():
	return EditorInterface.get_editor_viewport_2d()
func get_main_control_editor_node():
	return EditorInterface.get_base_control()


# ================================ EXIT ========================================
func reload_plugin():
	EditorInterface.call_deferred("set_plugin_enabled", "ridiculous_stream", false)
	EditorInterface.call_deferred("set_plugin_enabled", "ridiculous_stream", true)

func exit_twitcher():
	remove_import_plugin(twitcher.gif_importer_native)
	if twitcher.is_magick_available():
		remove_import_plugin(twitcher.gif_importer_imagemagick)
	remove_tool_menu_item("Regenerate Twitch REST Api");
	

func _exit_tree() -> void:
	save_rs_settings()
	exit_twitcher()
	if http_request: http_request.queue_free()
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	if gift: gift.queue_free()
	if shoutout_mng: shoutout_mng.queue_free()
	if wn_settings: wn_settings.queue_free()
	print("=================================== RIDICULOS STREAMING EXITING ===================================")


# ================================ DEBUG =======================================
enum DebugLog{RIDICULOUS, GIFT, POLYFRACT}
var logs_text : Array
var logs_type : Array
var stdout_on := true
var debug_print_ridiculous := true
var debug_print_gift := true
var debug_print_poly_fract := true
func log_print(text : String, type := DebugLog.RIDICULOUS):
	assert(logs_text.size() == logs_type.size(), "The logs arrays are not in sync")
	if not stdout_on: return

