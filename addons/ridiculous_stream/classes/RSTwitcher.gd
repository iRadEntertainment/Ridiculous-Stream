@tool
extends Node
class_name RSTwitcher

var main : RSMain

var twitch_service : TwitchService
var http_client_manager : HttpClientManager

var gif_importer_imagemagick: GifImporterImagemagick = GifImporterImagemagick.new();
var gif_importer_native: GifImporterNative = GifImporterNative.new();
var generator: TwitchAPIGenerator = TwitchAPIGenerator.new();

var is_ready := false
var is_connected := false




signal connected_to_twitch
signal disconnected_from_twitch


func start():
	twitch_service = TwitchService.new(main)
	http_client_manager = HttpClientManager.new(main)
	add_child(twitch_service)
	add_child(http_client_manager)
	
	is_ready = true


func connect_to_twitch():
	twitch_service.setup()
	is_connected = true


func connect_twitcher():
	#print("=================================== TWITCHER STARTED ===================================")
	#print("Twitch Plugin loading...")
	main.add_import_plugin(gif_importer_native)
	if is_magick_available():
		main.add_import_plugin(gif_importer_imagemagick)
	
	# !!! Change following in the project settings that the example works !!!
	TwitchSetting.broadcaster_id = str(main.settings.streamer_id)
	# twitch/auth/broadcaster_id 	< Your broadcaster id you can convert it here https://www.streamweasels.com/tools/convert-twitch-username-to-user-id/
	# twitch_settings.client_id = str(RSGlobals.client_id)
	# twitch/auth/client_id 		< you find while registering the application see readme for howto
	# twitch_settings.client_secret = settings.client_secret
	# twitch/auth/client_secret		< you find while registering the application see readme for howto
	TwitchSetting.irc_username = main.settings.channel
	# twitch/websocket/irc/username < Your username needed for IRC
	
	# twitch/auth/scopes/chat		< Add both Scopes chat_read, chat_edit
	
	var chat_bit_field = TwitchScopes.CHAT_READ.bit_value | TwitchScopes.CHAT_EDIT.bit_value
	var channel_bit_field = 0x7FFFFFF
	ProjectSettings.set_setting("twitch/auth/scopes/chat", chat_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/channel", channel_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/moderator", channel_bit_field)
	ProjectSettings.set_setting("twitch/auth/scopes/user", channel_bit_field)
	print(TwitchSetting.subscriptions)
	# TwitchSetting.setup()
	
	twitch_service.setup()
	
	print("Twitch Plugin loading ended")


func is_magick_available() -> bool:
	var transformer = MagicImageTransformer.new()
	return transformer.is_supported()
