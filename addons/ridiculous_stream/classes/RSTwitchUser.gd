extends Resource
class_name RSTwitchUser



## grabbed by twitch API
@export var username : String
@export var display_name : String
@export var user_id : int
@export var twitch_chat_color : Color
@export var profile_image_url : String

@export var is_streamer : bool
@export var auto_shoutout : bool
@export var auto_promotion : bool

@export var custom_chat_color : Color
@export var custom_notification_sfx : String
@export var custom_action : String
@export var custom_beans_params : Dictionary

@export var shoutout_description : String
@export var promotion_description : String

@export var last_shout_unix_time : int
