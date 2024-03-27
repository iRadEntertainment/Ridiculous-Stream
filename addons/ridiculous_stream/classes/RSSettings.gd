extends Resource
class_name RSSettings


## GIFT settings
@export var broadcaster_id : int = 0
@export var channel_name : String  = ""
@export var auto_connect : bool = false
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

## no-OBS-ws settings
@export var obs_websocket_password : String = "YvFuw8DQxdxCAsvJ"
