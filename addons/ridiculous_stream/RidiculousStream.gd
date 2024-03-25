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
var no_obs_ws : NoOBSWS
var shoutout_mng : RSShoutoutMng
var physics_space_rid : RID
var custom : RSCustom
var copilot : RSCoPilot
var wn_settings : Window
var wn_welcome : Window

signal gift_reloaded

#region INIT
# ================================ INIT ========================================

const TWITCH_SERVICE_AUTOLOAD_NAME: String = "TwitchService"
const HTTP_CLIENT_MANAGER_AUTOLOAD_NAME: String = "HttpClientManager"

var twitch_service : TwitchService
var http_client_manager : HttpClientManager


var twitch_settings: TwitchSetting
var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new();
var gif_importer_native: GifImporterNative = GifImporterNative.new();
var generator: TwitchAPIGenerator = TwitchAPIGenerator.new();

func add_ui():
	add_tool_menu_item("Regenerate Twitch REST Api", generator.generate_rest_api);

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()



func _enter_tree() -> void:
	print("=================================== RIDICULOS STREAMING STARTED ===================================")
	load_rs_settings()
	load_known_user()
	connect_twitcher()
	reload_gift()
	add_nodes()
	reload_dock()

func connect_twitcher():
	#print("=================================== TWITCHER STARTED ===================================")
	#print("Twitch Plugin loading...")
	add_ui()
	add_import_plugin(gif_importer_native)
	if is_magick_available():
		add_import_plugin(gif_importer_imagemagick)
	
	twitch_settings = TwitchSetting.new()
	# !!! Change following in the project settings that the example works !!!
	twitch_settings.broadcaster_id = str(settings.streamer_id)
	# twitch/auth/broadcaster_id 	< Your broadcaster id you can convert it here https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/
	twitch_settings.client_id = str(RSGlobals.client_id)
	# twitch/auth/client_id 		< you find while registering the application see readme for howto
	twitch_settings.client_secret = settings.client_secret
	# twitch/auth/client_secret		< you find while registering the application see readme for howto
	twitch_settings.irc_username = settings.channel
	# twitch/websocket/irc/username < Your username needed for IRC
	
	# twitch/auth/scopes/chat		< Add both Scopes chat_read, chat_edit
	
	var chat_bit_field = TwitchScopes.CHAT_READ.bit_value | TwitchScopes.CHAT_EDIT.bit_value
	var channel_bit_field = TwitchScopes.CHANNEL_MANAGE_GUEST_STAR.bit_value | TwitchScopes.CHAT_EDIT.bit_value
	ProjectSettings.set_setting("twitch/auth/scopes/chat", chat_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/channel", channel_bit_field)
	TwitchSetting.setup()
	
	twitch_service = TwitchService.new()
	add_child(twitch_service)
	http_client_manager = HttpClientManager.new()
	add_child(http_client_manager)
	
	twitch_service.main = self
	twitch_service.setup()
	
	print("Twitch Plugin loading ended")



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
	
	# --- windows
	hot_reaload_wn_settings()
	#wn_welcome = RSGlobals.wn_welcome_pack.instantiate()
	#EditorInterface.get_editor_main_screen().add_child(wn_welcome)

func hot_reaload_wn_settings():
	wn_settings = RSGlobals.wn_settings_pack.instantiate()
	wn_settings.visible = false
	wn_settings.main = self
	EditorInterface.get_base_control().add_child(wn_settings)
	wn_settings.start()


#region DOCK
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
	if gift:
		dock.start()
#endregion


#region GIFT
# ================================ GIFT ========================================
func reload_gift():
	#if gift:
		#if not gift.is_queued_for_deletion():
			#gift.queue_free()
	#gift = RSGift.new()
	if !gift:
		gift = RSGift.new()
		add_child(gift)
	gift.main = self
	gift.start()
	gift_reloaded.emit()
	#await gift.started



#region KNOWN_USERS
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
#endregion



#region EDITOR PHYSICS
# =========================== EDITOR PHYSICS ===================================

#endregion


#region LOAD/SAVE
# ========================== LOAD/SAVE CONFIG ==================================
func load_rs_settings():
	print("Loading settings from RSMain")
	settings = loader.load_settings()
	print(settings.channel)
	print(settings.bot_name)
	print(settings.streamer_id)
func save_rs_settings():
	print("Saving settings from RSMain")
	print(settings)
	loader.save_settings(settings)
#endregion


#region UTILS
# =============================== UTILS =======================================
func get_current_code_edit() -> CodeEdit:
	var editor_script := EditorInterface.get_script_editor().get_current_editor()
	return editor_script.get_base_editor() as CodeEdit
func get_2d_main_screen():
	return EditorInterface.get_editor_viewport_2d()
func get_main_control_editor_node():
	return EditorInterface.get_base_control()
#endregion



#region EXIT
# ================================ EXIT ========================================
func reload_plugin():
	EditorInterface.call_deferred("set_plugin_enabled", "ridiculous_stream", false)
	EditorInterface.call_deferred("set_plugin_enabled", "ridiculous_stream", true)

func _exit_tree() -> void:
	remove_import_plugin(gif_importer_native)
	if is_magick_available():
		remove_import_plugin(gif_importer_imagemagick)
	#remove_autoload_singleton(TWITCH_SERVICE_AUTOLOAD_NAME);
	#remove_autoload_singleton(HTTP_CLIENT_MANAGER_AUTOLOAD_NAME);
	print("=================================== TWITCHER EXITING ===================================")
	
	save_rs_settings()
	#if settings: settings.queue_free()
	#if globals: globals.queue_free()
	#if loader: loader.queue_free()
	if http_request: http_request.queue_free()
	if dock:
		remove_control_from_docks(dock)
		dock.queue_free()
	if gift: gift.queue_free()
	if shoutout_mng: shoutout_mng.queue_free()
	#if custom: custom.queue_free()
	if wn_settings: wn_settings.queue_free()
	if wn_welcome: wn_welcome.queue_free()
	print("=================================== RIDICULOS STREAMING EXITING ===================================")
#endregion


#region DEBUG
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
	#if type == DebugLog.RIDICULOUS and debug_print_ridiculous:
	print(text)
#endregion
















