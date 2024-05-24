# ================== #
#      RSMain.gd     #
# ================== #

@tool
extends EditorPlugin
class_name RSMain

var globals := RSGlobals.new()
var loader := RSExternalLoader.new()
var http_request := HTTPRequest.new()

var pnl_settings : RSPnlSettings
var dock : RSDock
var twitcher : RSTwitcher
var no_obs_ws : NoOBSWS

var shoutout_mng : RSShoutoutMng
var custom : RSCustom
var copilot : RSCoPilot
var vetting : RSVetting

var known_users := {}

# ================================ INIT ========================================
func _enter_tree() -> void:
	print("=================================== RIDICULOS STREAMING STARTED ===================================")
	RSSettings.setup()
	load_rs_settings()
	load_known_user()
	reload_twitcher()
	add_tool_generate_rest_api()
	add_nodes()
	hot_reload_pnl_settings()
	reload_dock()

func _has_main_screen():
	return true
func _make_visible(visible):
	if pnl_settings:
		pnl_settings.visible = visible
func _get_plugin_name():
	return "RSSettings"
func _get_plugin_icon():
	return load("res://addons/ridiculous_stream/ui/settings_icon.png")


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
	vetting = RSVetting.new()
	vetting.main = self
	vetting.start()
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
	no_obs_ws.start(self)


func hot_reload_pnl_settings():
	var pnl_settings_exists = pnl_settings != null
	if pnl_settings_exists:
		pnl_settings.queue_free()
	pnl_settings = RSGlobals.pnl_settings_pack.instantiate()
	pnl_settings.name = "panel_settings"
	pnl_settings.visible = pnl_settings_exists
	pnl_settings.main = self
	EditorInterface.get_editor_main_screen().add_child(pnl_settings)
	pnl_settings.start()


# ================================ DOCK ========================================
func reload_dock():
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	dock = RSGlobals.dock_pack.instantiate()
	dock.main = self
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, dock)
	var dock_cont := dock.get_parent() as TabContainer
	dock_cont.move_child(dock, 1)
	dock_cont.current_tab = 1
	if twitcher:
		dock.start()


# =============================== KNOWN USERS ==================================
func load_known_user(username := ""):
	if username.is_empty():
		known_users = await loader.load_all_user()
	else:
		known_users[username] = await loader.load_userfile(username)
func save_known_users():
	loader.save_all_user(known_users)
func get_known_user(username : String) -> RSTwitchUser:
	var user = null
	if username in known_users.keys():
		user = known_users[username]
	return user


# ========================== LOAD/SAVE CONFIG ==================================
func load_rs_settings():
	print("Loading settings from RSMain")
	loader.load_settings()
	
func save_rs_settings():
	print("Saving settings from RSMain")
	#RSSettings.client_id = ProjectSettings.get_setting("twitch/auth/client_id")
	#RSSettings.client_secret = ProjectSettings.get_setting("twitch/auth/client_secret")
	#RSSettings.authorization_flow = ProjectSettings.get_setting("twitch/auth/authorization_flow")
	#RSSettings.broadcaster_id = ProjectSettings.get_setting("twitch/auth/broadcaster_id")
	loader.save_settings()


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
	if twitcher: twitcher.queue_free()


func _exit_tree() -> void:
	#save_rs_settings()
	exit_twitcher()
	if http_request: http_request.queue_free()
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	if shoutout_mng: shoutout_mng.queue_free()
	print("=================================== RIDICULOS STREAMING EXITING ===================================")
