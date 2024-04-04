@tool
extends Resource
class_name RSTwitchUser

var username : String
var display_name : String
var user_id : int
var twitch_chat_color : Color
var profile_image_url : String

var is_streamer : bool
var auto_shoutout : bool
var auto_promotion : bool

var custom_chat_color : Color
var custom_notification_sfx : String
var custom_action : String
var custom_beans_params : RSBeansParam

var shoutout_description : String
var promotion_description : String
var last_shout_unix_time : int


func to_dict() -> Dictionary:
	var d = {}
	d["username"] = username
	d["display_name"] = display_name
	d["user_id"] = user_id
	d["twitch_chat_color"] = twitch_chat_color.to_html()
	d["profile_image_url"] = profile_image_url
	d["is_streamer"] = is_streamer
	d["auto_shoutout"] = auto_shoutout
	d["auto_promotion"] = auto_promotion
	d["custom_chat_color"] = custom_chat_color.to_html()
	d["custom_notification_sfx"] = custom_notification_sfx
	d["custom_action"] = custom_action

	if custom_beans_params == null:
		d["custom_beans_params"] = null
	elif (custom_beans_params is RSBeansParam):
		d["custom_beans_params"] = custom_beans_params.to_dict()
	elif typeof(custom_beans_params) == TYPE_DICTIONARY:
		if custom_beans_params.is_empty():
			d["custom_beans_params"] = null
		else:
			if "scale" in custom_beans_params.keys():
				if typeof(custom_beans_params["scale"]) == TYPE_VECTOR2:
					custom_beans_params["scale"] = [custom_beans_params["scale"].x, custom_beans_params["scale"].y]
				d["custom_beans_params"] = custom_beans_params
			if "destroy_shard_params" in custom_beans_params.keys():
				var destroy_shard_params = custom_beans_params["destroy_shard_params"]
				if not destroy_shard_params:
					d["custom_beans_params"]["destroy_shard_params"] = null
				elif destroy_shard_params.is_empty():
					d["custom_beans_params"]["destroy_shard_params"] = null
				else:
					destroy_shard_params["destroy_shard_params"] = null
					if "scale" in destroy_shard_params.keys():
						if typeof(destroy_shard_params["scale"]) == TYPE_VECTOR2:
							destroy_shard_params["scale"] = [destroy_shard_params["scale"].x, destroy_shard_params["scale"].y]
					d["custom_beans_params"]["destroy_shard_params"] = destroy_shard_params

	
	d["shoutout_description"] = shoutout_description
	d["promotion_description"] = promotion_description
	d["last_shout_unix_time"] = last_shout_unix_time
	return d


func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(d: Dictionary) -> RSTwitchUser:
	var user := RSTwitchUser.new()
	user.username = d["username"]
	user.display_name = d["display_name"]
	user.user_id = d["user_id"]
	user.twitch_chat_color = Color.from_string(d["twitch_chat_color"], Color.BLACK)
	user.profile_image_url = d["profile_image_url"]
	user.is_streamer = d["is_streamer"]
	user.auto_shoutout = d["auto_shoutout"]
	user.auto_promotion = d["auto_promotion"]
	user.custom_chat_color = Color.from_string(d["custom_chat_color"], Color.BLACK)
	user.custom_notification_sfx = d["custom_notification_sfx"]
	user.custom_action = d["custom_action"]
	if d["custom_beans_params"] != null:
		user.custom_beans_params = RSBeansParam.from_json(d["custom_beans_params"])
	user.shoutout_description = d["shoutout_description"]
	user.promotion_description = d["promotion_description"]
	user.last_shout_unix_time = d["last_shout_unix_time"]
	return user
