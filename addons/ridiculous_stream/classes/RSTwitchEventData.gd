extends RefCounted
class_name RSTwitchEventData

var type : String

var user_id : int
var username : String     # from twitch API username is "user_login"
var display_name : String # from twitch API display_name is "user_name"
var followed_at : String
var from_broadcaster_user_id : int
var from_broadcaster_username : String     # from twitch API username is "user_login"
var from_broadcaster_display_name : String # from twitch API display_name is "user_name"
var viewers : int
var user_input : String
var status : String
var reward_title : String
var reward_cost : int
var reward_prompt : String
var is_anonymous : bool
var message : String
var bits : int
var tier : int
var is_gift : bool


static func create_from_event_body(_type : String, body : Dictionary) -> RSTwitchEventData:
	var data := RSTwitchEventData.new()
	data.type = _type
	if body.has("user_id"): data.user_id = body.user_id as int
	if body.has("user_login"): data.username = body.user_login
	if body.has("user_name"): data.display_name = body.user_name
	match _type:
		"channel.follow":
			data.followed_at = body.followed_at
		"channel.channel_points_custom_reward_redemption.add":
			data.user_input = body.user_input
			data.status = body.status
			data.reward_title = body.reward.title
			data.reward_cost = body.reward.cost as int
			data.reward_prompt = body.reward.prompt
		"channel.raid":
			data.from_broadcaster_user_id = body.from_broadcaster_user_id as int
			data.from_broadcaster_username = body.from_broadcaster_user_login
			data.from_broadcaster_display_name = body.from_broadcaster_user_name
			data.viewers = body.viewers as int
		"channel.cheer":
			data.is_anonymous = body.is_anonymous
			data.message = body.message
			data.bits = body.bits as int
		"channel.subscribe":
			data.tier = body.tier as int
			data.is_gift = body.is_gift
	return data






