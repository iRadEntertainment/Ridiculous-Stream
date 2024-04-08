@tool
extends Resource
class_name RSSettings


## Twitch settings
var client_id : String = ""
var client_secret : String = ""
var authorization_flow : String = str(TwitchSetting.FLOW_AUTHORIZATION_CODE)
var broadcaster_id : int = 0
var user_login : String = ""
var channel_name : String  = ""
var auto_connect : bool = false
var scopes := {
	"twitch/auth/scopes/chat": int(0),
	"twitch/auth/scopes/channel": int(0),
	"twitch/auth/scopes/moderator": int(0),
	"twitch/auth/scopes/user": int(0),
}
var eventsubs := {}

## TwitchChatCoPilot settings
var copilot_always_disabled := false
var max_messages_in_chat : int = 100

## no-OBS-ws settings
static var _obs_autoconnect: Property
static var obs_autoconnect : bool :
	get: return _obs_autoconnect.get_val()
	set(val): _obs_autoconnect.set_val(val)

static var _obs_websocket_port: Property
static var obs_websocket_port : String : #= "YvFuw8DQxdxCAsvJ":
	get: return _obs_websocket_port.get_val()
	set(val): _obs_websocket_port.set_val(val)

static var _obs_websocket_password: Property
static var obs_websocket_password : String : #= "YvFuw8DQxdxCAsvJ":
	get: return _obs_websocket_password.get_val()
	set(val): _obs_websocket_password.set_val(val)


## RSLogger
const LOGGER_NAME_RS = "Ridiculous Stream"
const LOGGER_NAME_NOOBSWS = "OBS Websocket"
const LOGGER_NAME_SHOUTOUT = "Shoutout Manager"
const LOGGER_NAME_CUSTOM = "RSCustom"


const ALL_LOGGERS: Array[String] = [
	LOGGER_NAME_RS,
	LOGGER_NAME_NOOBSWS,
	LOGGER_NAME_SHOUTOUT,
	LOGGER_NAME_CUSTOM,
]

static var _log_enabled: Property
static var log_enabled: Array:
	get: return get_log_enabled()


class Property extends TwitchSetting.Property:
	# just make a class copy
	pass

static func setup():
	_obs_autoconnect = Property.new("RidiculousStream/general/OBS Websocket/obs_autoconnect", false).as_bool("Do you need a description?").basic()
	_obs_websocket_port = Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_port", 4455).as_num().basic()
	_obs_websocket_password = Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_password").as_password("Fetch the OBS web socket password from OBS").basic()
	_log_enabled = Property.new("RidiculousStream/general/logging/enabled").as_bit_field(ALL_LOGGERS as Array[String])

static func get_log_enabled() -> Array[String]:
	var result: Array[String] = [];
	# Other classes can be initialized before the settings and use the log.
	if _log_enabled == null:
		return result;
	var bitset = _log_enabled.get_val();
	if typeof(bitset) == TYPE_STRING && bitset == "" || typeof(bitset) == TYPE_INT && bitset == 0:
		return result
	for logger_idx: int in range(ALL_LOGGERS.size()):
		var bit_value = 1 << logger_idx;
		if bitset & bit_value == bit_value:
			result.append(ALL_LOGGERS[logger_idx])
	return result

static func is_log_enabled(logger: String) -> bool:
	return log_enabled.find(logger) != -1


static func retrieve_eventsub_project_settings() -> Dictionary:
	var d = {}
	var keys = []
	for property : Dictionary in ProjectSettings.get_property_list():
		var key : String = str(property.name)
		if key.begins_with("twitch/eventsub/") and ProjectSettings.get_setting(key):
			keys.append(key)
	
	for key in keys:
		d[key] = ProjectSettings.get_setting(key)
	return d

static func retrieve_scopes_from_project_settings(scopes: Dictionary) -> Dictionary:
	for key in scopes.keys():
		var value : int = int(ProjectSettings.get_setting(key))
		scopes[key] = value
	return scopes

func assign_scopes_to_project_settings() -> void:
	for key in scopes.keys():
		var value := int(scopes[key])
		ProjectSettings.set_setting(key, value)
		
func assign_eventsub_to_project_settings() -> void:
	for key in eventsubs.keys():
		var value = eventsubs[key]
		if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
			value = str(value)
		ProjectSettings.set_setting(key, value)
		

func to_dict() -> Dictionary:
	var d = {}
	scopes = retrieve_scopes_from_project_settings(scopes)
	d["scopes"] = scopes
	eventsubs = retrieve_eventsub_project_settings()
	d["eventsubs"] = eventsubs
	
	d["client_id"] = client_id
	d["client_secret"] = client_secret
	d["authorization_flow"] = authorization_flow
	d["broadcaster_id"] = broadcaster_id
	d["user_login"] = user_login
	d["channel_name"] = channel_name
	d["auto_connect"] = auto_connect
	d["copilot_always_disabled"] = copilot_always_disabled
	d["max_messages_in_chat"] = max_messages_in_chat
	d["obs_autoconnect"] = obs_autoconnect
	d["obs_websocket_port"] = obs_websocket_port
	d["obs_websocket_password"] = obs_websocket_password
	d["log_enabled"] = log_enabled
	return d

func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(d: Dictionary) -> RSSettings:
	var settings = RSSettings.new()
	if d.has("scopes") && d["scopes"] != null: settings.scopes = d["scopes"]
	if d.has("eventsubs") && d["eventsubs"] != null: settings.eventsubs = d["eventsubs"]
	
	if d.has("client_id") && d["client_id"] != null: settings.client_id = d["client_id"]
	if d.has("client_secret") && d["client_secret"] != null: settings.client_secret = d["client_secret"]
	if d.has("authorization_flow") && d["authorization_flow"] != null: settings.authorization_flow = d["authorization_flow"]
	if d.has("broadcaster_id") && d["broadcaster_id"] != null: settings.broadcaster_id = d["broadcaster_id"]
	if d.has("user_login") && d["user_login"] != null: settings.user_login = d["user_login"]
	if d.has("channel_name") && d["channel_name"] != null: settings.channel_name = d["channel_name"]
	if d.has("auto_connect") && d["auto_connect"] != null: settings.auto_connect = d["auto_connect"]
	if d.has("copilot_always_disabled") && d["copilot_always_disabled"] != null: settings.copilot_always_disabled = d["copilot_always_disabled"]
	if d.has("max_messages_in_chat") && d["max_messages_in_chat"] != null: settings.max_messages_in_chat = d["max_messages_in_chat"]
	if d.has("obs_autoconnect") && d["obs_autoconnect"] != null: settings.obs_autoconnect = d["obs_autoconnect"]
	if d.has("obs_websocket_port") && d["obs_websocket_port"] != null: settings.obs_websocket_port = d["obs_websocket_port"]
	if d.has("obs_websocket_password") && d["obs_websocket_password"] != null: settings.obs_websocket_password = d["obs_websocket_password"]
	if d.has("log_enabled") && d["log_enabled"] != null: settings.log_enabled = d["log_enabled"]
	return settings
