extends RefCounted
class_name RSSettings


## Twitch settings
static var _client_id : TwitchSetting.Property
static var client_id : String :
	get: return _client_id.get_val()
	set(value):
		if TwitchSetting.is_initialized:
			TwitchSetting.client_id = value
		_client_id.set_val(value)
static var _client_secret : TwitchSetting.Property
static var client_secret : String :
	get: return _client_secret.get_val()
	set(value):
		if TwitchSetting.is_initialized:
			TwitchSetting.client_secret = value
		_client_secret.set_val(value)
static var _authorization_flow : TwitchSetting.Property
static var authorization_flow : String :
	get: return _authorization_flow.get_val()
	set(value):
		if TwitchSetting.is_initialized:
			TwitchSetting.authorization_flow = value
		_authorization_flow.set_val(value)
static var _broadcaster_id : TwitchSetting.Property
static var broadcaster_id : int :
	get: return _broadcaster_id.get_val()
	set(value):
		if TwitchSetting.is_initialized:
			TwitchSetting.broadcaster_id = str(value)
		_broadcaster_id.set_val(value)
static var _user_login : TwitchSetting.Property
static var user_login : String :
	get: return _user_login.get_val()
	set(value): _user_login.set_val(value)
static var _channel_name : TwitchSetting.Property
static var channel_name : String  :
	get: return _channel_name.get_val()
	set(value): _channel_name.set_val(value)
static var _auto_connect : TwitchSetting.Property
static var auto_connect : bool :
	get: return _auto_connect.get_val()
	set(value): _auto_connect.set_val(value)

static var _max_messages_in_chat : TwitchSetting.Property
static var max_messages_in_chat : int :
	get: return _max_messages_in_chat.get_val()
	set(value): _max_messages_in_chat.set_val(value)

const SCOPES_DEFAULT_DIC := {
			"twitch/auth/scopes/chat": int(0),
			"twitch/auth/scopes/channel": int(0),
			"twitch/auth/scopes/moderator": int(0),
			"twitch/auth/scopes/user": int(0),
		}
static var scopes : Dictionary :
	get: return get_scopes()
	set(value): set_scopes(value)

static var eventsubs : Dictionary :
	get: return get_eventsubs()
	set(value): set_eventsubs(value)


## no-OBS-ws settings
static var _obs_autoconnect: TwitchSetting.Property
static var obs_autoconnect : bool :
	get: return _obs_autoconnect.get_val()
	set(val): _obs_autoconnect.set_val(val)

static var _obs_websocket_port: TwitchSetting.Property
static var obs_websocket_port : int :
	get: return _obs_websocket_port.get_val()
	set(val): _obs_websocket_port.set_val(val)

static var _obs_websocket_password: TwitchSetting.Property
static var obs_websocket_password : String : #= "YvFuw8DQxdxCAsvJ":
	get: return _obs_websocket_password.get_val()
	set(val): _obs_websocket_password.set_val(val)


## RSLogger
const LOGGER_NAME_RS = "Ridiculous Stream"
const LOGGER_NAME_NOOBSWS = "OBS Websocket"
const LOGGER_NAME_SHOUTOUT = "Shoutout Manager"
const LOGGER_NAME_CUSTOM = "RSCustom"
const LOGGER_NAME_VETTING = "RSVetting"


const ALL_LOGGERS: Array[String] = [
	LOGGER_NAME_RS,
	LOGGER_NAME_NOOBSWS,
	LOGGER_NAME_SHOUTOUT,
	LOGGER_NAME_CUSTOM,
	LOGGER_NAME_VETTING,
]

static var _log_enabled: TwitchSetting.Property
static var log_enabled: Array:
	get: return get_log_enabled()


static func setup():
	_client_id = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/client_id", RSGlobals.IRADDEV_CLIENT_ID).as_str("Twitch App client ID").basic()
	_client_secret = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/client_secret").as_password("Twitch App client secret").basic()
	_authorization_flow = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/authorization_flow", "AuthorizationCodeGrantFlow").as_select([TwitchSetting.FLOW_IMPLICIT, TwitchSetting.FLOW_CLIENT_CREDENTIALS, TwitchSetting.FLOW_AUTHORIZATION_CODE, TwitchSetting.FLOW_DEVICE_CODE_GRANT], false)
	_broadcaster_id = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/broadcaster_id").as_num().basic()
	_user_login = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/user_login").as_str().basic()
	_channel_name = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/channel_name").as_str().basic()
	_auto_connect = TwitchSetting.Property.new("RidiculousStream/general/RSTwitch/auto_connect", false).as_bool().basic()
	
	_obs_autoconnect = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_autoconnect", false).as_bool().basic()
	_obs_autoconnect = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_autoconnect", false).as_bool().basic()
	_obs_websocket_port = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_port", 4455).as_num().basic()
	_obs_websocket_password = TwitchSetting.Property.new("RidiculousStream/general/OBS Websocket/obs_websocket_password").as_password("Fetch the OBS web socket password from OBS").basic()
	_log_enabled = TwitchSetting.Property.new("RidiculousStream/general/logging/enabled").as_bit_field(ALL_LOGGERS as Array[String])
	
	_max_messages_in_chat = TwitchSetting.Property.new("RidiculousStream/general/Others/max_messages_in_chat", 100).as_num().basic()

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


static func get_scopes() -> Dictionary:
	for key in SCOPES_DEFAULT_DIC.keys():
		var value : int = int(ProjectSettings.get_setting(key))
		scopes[key] = value
	return scopes
static func set_scopes(values : Dictionary) -> void:
	for key in SCOPES_DEFAULT_DIC.keys():
		var value := int(values[key])
		ProjectSettings.set_setting(key, value)

static func get_eventsubs() -> Dictionary:
	var keys = []
	for property : Dictionary in ProjectSettings.get_property_list():
		var key : String = str(property.name)
		if key.begins_with("twitch/eventsub/") and ProjectSettings.get_setting(key):
			keys.append(key)
	var d = {}
	for key in keys:
		d[key] = ProjectSettings.get_setting(key)
	return d
static func set_eventsubs(values : Dictionary) -> void:
	for key in values.keys():
		var value = values[key]
		if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
			value = str(value)
		ProjectSettings.set_setting(key, value)


static func to_dict() -> Dictionary:
	var d = {}
	d["scopes"] = scopes
	d["eventsubs"] = eventsubs
	
	d["client_id"] = client_id
	d["client_secret"] = client_secret
	d["authorization_flow"] = authorization_flow
	d["broadcaster_id"] = broadcaster_id
	d["user_login"] = user_login
	d["channel_name"] = channel_name
	d["auto_connect"] = auto_connect
	
	d["obs_autoconnect"] = obs_autoconnect
	d["obs_websocket_port"] = obs_websocket_port
	d["obs_websocket_password"] = obs_websocket_password
	d["log_enabled"] = log_enabled
	
	d["max_messages_in_chat"] = max_messages_in_chat
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
	
	if d.has("obs_autoconnect") && d["obs_autoconnect"] != null: settings.obs_autoconnect = d["obs_autoconnect"]
	if d.has("obs_websocket_port") && d["obs_websocket_port"] != null: settings.obs_websocket_port = d["obs_websocket_port"]
	if d.has("obs_websocket_password") && d["obs_websocket_password"] != null: settings.obs_websocket_password = d["obs_websocket_password"]
	if d.has("log_enabled") && d["log_enabled"] != null: settings.log_enabled = d["log_enabled"]
	
	if d.has("max_messages_in_chat") && d["max_messages_in_chat"] != null: settings.max_messages_in_chat = d["max_messages_in_chat"]
	return settings
