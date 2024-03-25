extends Resource
class_name RSSettings


## GIFT settings
@export var bot_name : String = ""
@export var streamer_id : int = 443367221
@export var client_secret : String = ""
@export var channel : String  = ""
@export var scope := [
	RSGlobals.TwScope.CHAT_READ,
	RSGlobals.TwScope.CHAT_EDIT,
	RSGlobals.TwScope.SO,
	RSGlobals.TwScope.SUBS,
	RSGlobals.TwScope.FOLLOWERS,
	RSGlobals.TwScope.REDEMPTIONS,
	RSGlobals.TwScope.POLLS,
	RSGlobals.TwScope.BITS,
]


## TwitchChatCoPilot settings
@export var copilot_always_disabled := false
@export var max_messages_in_chat : int = 100


## TwitchChatCoPilot settings
@export var obs_websocket_password : String = "YvFuw8DQxdxCAsvJ"

