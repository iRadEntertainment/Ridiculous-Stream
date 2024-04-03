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

## TwitchChatCoPilot settings
var copilot_always_disabled := false
var max_messages_in_chat : int = 100

## no-OBS-ws settings
var obs_websocket_password : String = "YvFuw8DQxdxCAsvJ"


static func retrieve_scopes_from_project_settings(scopes: Dictionary) -> Dictionary:
	for key in scopes.keys():
		var value : int = int(ProjectSettings.get_setting(key))
		scopes[key] = value
	return scopes

func assign_scopes_to_project_settings() -> void:
	for key in scopes.keys():
		var value := int(scopes[key])
		ProjectSettings.set_setting(key, value)
		

func to_dict() -> Dictionary:
	var d = {}
	scopes = retrieve_scopes_from_project_settings(scopes)
	d["scopes"] = scopes
	
	d["client_id"] = client_id
	d["client_secret"] = client_secret
	d["authorization_flow"] = authorization_flow
	d["broadcaster_id"] = broadcaster_id
	d["user_login"] = user_login
	d["channel_name"] = channel_name
	d["auto_connect"] = auto_connect
	d["copilot_always_disabled"] = copilot_always_disabled
	d["max_messages_in_chat"] = max_messages_in_chat
	d["obs_websocket_password"] = obs_websocket_password
	return d

func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(d: Dictionary) -> RSSettings:
	var settings = RSSettings.new()
	if d.has("scopes") && d["scopes"] != null: settings.scopes = d["scopes"]
	
	if d.has("client_id") && d["client_id"] != null: settings.client_id = d["client_id"]
	if d.has("client_secret") && d["client_secret"] != null: settings.client_secret = d["client_secret"]
	if d.has("authorization_flow") && d["authorization_flow"] != null: settings.authorization_flow = d["authorization_flow"]
	if d.has("broadcaster_id") && d["broadcaster_id"] != null: settings.broadcaster_id = d["broadcaster_id"]
	if d.has("user_login") && d["user_login"] != null: settings.user_login = d["user_login"]
	if d.has("channel_name") && d["channel_name"] != null: settings.channel_name = d["channel_name"]
	if d.has("auto_connect") && d["auto_connect"] != null: settings.auto_connect = d["auto_connect"]
	if d.has("copilot_always_disabled") && d["copilot_always_disabled"] != null: settings.copilot_always_disabled = d["copilot_always_disabled"]
	if d.has("max_messages_in_chat") && d["max_messages_in_chat"] != null: settings.max_messages_in_chat = d["max_messages_in_chat"]
	if d.has("obs_websocket_password") && d["obs_websocket_password"] != null: settings.obs_websocket_password = d["obs_websocket_password"]
	return settings
