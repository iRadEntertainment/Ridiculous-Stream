@tool
extends Node
class_name RSTwitcher

var main : RSMain

var twitch_service : TwitchService
var http_client_manager : HttpClientManager

var irc : TwitchIRC
var api : TwitchRestAPI
var eventsub: TwitchEventsub
var commands: TwitchCommandHandler

var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new();
var gif_importer_native: GifImporterNative = GifImporterNative.new();
var generator: TwitchAPIGenerator = TwitchAPIGenerator.new();

var is_ready := false
var is_connected_to_twitch := false

# irc
signal received_chat_message(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg)

# api
signal channel_points_redeemed(RSTwitchEventData)
signal followed(RSTwitchEventData)
signal raided(RSTwitchEventData)
signal subscribed(RSTwitchEventData)
signal cheered(RSTwitchEventData)

signal connected_to_twitch


func start() -> void:
	twitch_service = TwitchService.new(main)
	http_client_manager = HttpClientManager.new(main)
	add_child(twitch_service)
	add_child(http_client_manager)
	api = twitch_service.api
	irc = twitch_service.irc
	eventsub = twitch_service.eventsub
	commands = twitch_service.commands

	irc.received_privmsg.connect(_on_irc_received_privmsg)
	eventsub.event.connect(on_event)
	setup()

	is_ready = true


func connect_to_twitch():
	await twitch_service.setup()
	var user_response := await api.get_users([str(main.settings.broadcaster_id)], [])
	var user := user_response.data[0]
	main.settings.channel_name = user.login
	irc.join_channel(main.settings.channel_name)
	is_connected_to_twitch = true
	connected_to_twitch.emit()

func _on_irc_received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	received_chat_message.emit(channel_name, username, message, tags)


func setup():
	main.add_import_plugin(gif_importer_native)
	if is_magick_available():
		main.add_import_plugin(gif_importer_imagemagick)
	
	TwitchSetting.auth_cache = RSExternalLoader.get_config_path() + "auth.conf"
	TwitchSetting.cache_badge = RSExternalLoader.get_config_path() + "badges"
	TwitchSetting.cache_cheermote = RSExternalLoader.get_config_path() + "cheermotes"
	TwitchSetting.cache_emote = RSExternalLoader.get_config_path() + "emotes"
	
	TwitchSetting.broadcaster_id = str(main.settings.broadcaster_id)
	TwitchSetting.client_id = str(RSGlobals.client_id)
	TwitchSetting.irc_username = main.settings.channel_name
	
	# twitch/auth/scopes/chat		< Add both Scopes chat_read, chat_edit
	
	var chat_bit_field = TwitchScopes.CHAT_READ.bit_value | TwitchScopes.CHAT_EDIT.bit_value
	var channel_bit_field = 0x7FFFFFF
	ProjectSettings.set_setting("twitch/auth/scopes/chat", chat_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/channel", channel_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/moderator", channel_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/user", channel_bit_field)


func on_event(type : String, _data : Dictionary) -> void:
	var data := RSTwitchEventData.create_from_event_body(type, _data)
	match(type):
		"channel.follow": followed.emit(data)
		"channel.channel_points_custom_reward_redemption.add": channel_points_redeemed.emit(data)
		"channel.raid": raided.emit(data)
		"channel.cheer": cheered.emit(data)
		"channel.subscribe": subscribed.emit(data)

func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()

func chat(msg : String):
	irc.chat(msg, main.settings.channel_name)

func gather_user_info(username : String) -> RSTwitchUser:
	var user = RSTwitchUser.new()
	var response : TwitchGetUsersResponse = await( api.get_users([], [username]) )
	var user_ids : Dictionary = response.to_dict()
	if user_ids.data.is_empty(): return
	user.user_id = user_ids.data[0]["id"]
	user.display_name = user_ids.data[0]["display_name"]
	user.username = user_ids.data[0]["login"]
	user.profile_image_url = user_ids.data[0]["profile_image_url"]
	return user