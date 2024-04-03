@tool
extends Node
class_name RSTwitcher

var main : RSMain
var http_client_manager : HttpClientManager

var irc : TwitchIRC
var api : TwitchRestAPI
var eventsub: TwitchEventsub
var commands: TwitchCommandHandler
var log: TwitchLogger
var auth: TwitchAuth
var icon_loader: TwitchIconLoader
var eventsub_debug: TwitchEventsub
var cheer_repository: TwitchCheerRepository
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
	setup()
	http_client_manager = HttpClientManager.new(main)
	add_child(http_client_manager)
	#---------------
	log = TwitchLogger.new(TwitchSetting.LOGGER_NAME_SERVICE)
	log.i("Setup")
	auth = TwitchAuth.new(main)
	api = TwitchRestAPI.new(auth)
	icon_loader = TwitchIconLoader.new(api, main)
	eventsub = TwitchEventsub.new(api)
	eventsub_debug = TwitchEventsub.new(api, false)
	irc = TwitchIRC.new(auth)
	
	gif_importer_imagemagick = GifImporterImagemagick.new()
	gif_importer_native = GifImporterNative.new()
	generator = TwitchAPIGenerator.new()
	commands = TwitchCommandHandler.new()
	#---------------
	irc.received_privmsg.connect(_on_irc_received_privmsg)
	eventsub.event.connect(on_event)
	is_ready = true
	if main.settings.auto_connect:
		connect_to_twitch()


func setup():
	TwitchSetting.setup()
	
	TwitchSetting.auth_cache = RSExternalLoader.get_config_path() + "auth.conf"
	TwitchSetting.cache_badge = RSExternalLoader.get_config_path() + "badges"
	TwitchSetting.cache_cheermote = RSExternalLoader.get_config_path() + "cheermotes"
	TwitchSetting.cache_emote = RSExternalLoader.get_config_path() + "emotes"
	
	TwitchSetting.broadcaster_id = str(main.settings.broadcaster_id)
	TwitchSetting.client_id = main.settings.client_id
	TwitchSetting.client_secret = main.settings.client_secret
	TwitchSetting.authorization_flow = main.settings.authorization_flow
	TwitchSetting.irc_username = main.settings.user_login
	
	main.settings.assign_scopes_to_project_settings()
	
	main.add_import_plugin(gif_importer_native)
	if is_magick_available():
		main.add_import_plugin(gif_importer_imagemagick)


func connect_to_twitch():
	log.i("Start")
	await auth.ensure_authentication()
	print("Twitcher: auth ensured")
	if main.settings.user_login in [null, ""]:
		var user_response := await api.get_users([str(main.settings.broadcaster_id)], [])
		var user := user_response.data[0]
		main.settings.user_login = user.login
		main.settings.channel_name = user.login
	await _init_chat()
	print("Twitcher: chat initialized")
	_init_eventsub()
	if TwitchSetting.use_test_server:
		eventsub_debug.connect_to_eventsub(TwitchSetting.eventsub_test_server_url)
	_init_cheermotes()
	log.i("Initialized and ready")
	
	is_connected_to_twitch = true
	connected_to_twitch.emit()


func _init_chat() -> void:
	irc.received_privmsg.connect(commands.handle_chat_command);
	irc.received_whisper.connect(commands.handle_whisper_command);
	irc.connect_to_irc();
	irc.join_channel(main.settings.channel_name)
	icon_loader.do_preload();
	await icon_loader.preload_done;

func _init_eventsub() -> void:
	eventsub.connect_to_eventsub(TwitchSetting.eventsub_live_server_url)
	if !eventsub.event.is_connected(on_event):
		eventsub.event.connect(on_event)

## Get data about a user by USER_ID see get_user for by username
func get_user_by_id(user_id: String) -> TwitchUser:
	if user_id == null || user_id == "": return null;
	var user_data : TwitchGetUsersResponse = await api.get_users([user_id], []);
	if user_data.data.is_empty(): return null;
	return user_data.data[0];

## Get data about a user by USERNAME see get_user_by_id for by user_id
func get_user(username: String) -> TwitchUser:
	var user_data : TwitchGetUsersResponse = await api.get_users([], [username]);
	return user_data.data[0];


## Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
## which API versions are available and which conditions are required.
func subscribe_event(event_name : String, version : String, conditions : Dictionary, session_id: String):
	eventsub.subscribe_event(event_name, version, conditions, session_id)

## Waits for connection to eventsub. Eventsub is ready to subscribe events.
func wait_for_connection() -> void:
	await eventsub.wait_for_connection();

func _on_irc_received_privmsg(channel_name: String, username: String, message: String, tags: TwitchTags.PrivMsg):
	received_chat_message.emit(channel_name, username, message, tags)

func chat(msg : String, channel_name := ""):
	if channel_name == "":
		irc.chat(msg, main.settings.channel_name)
	else:
		irc.chat(msg, channel_name)

func whisper(message: String, username: String) -> void:
	log.e("Whipser from bots aren't supported by Twitch anymore. See https://dev.twitch.tv/docs/irc/chat-commands/ at /w")

## Returns the definition of emotes for given channel or for the global emotes.
## Key: EmoteID as String ; Value: TwitchGlobalEmote | TwitchChannelEmote
func get_emotes_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_emotes(channel_id);

## Returns the definition of badges for given channel or for the global bages.
## Key: category / versions / badge_id ; Value: TwitchChatBadge
func get_badges_data(channel_id: String = "global") -> Dictionary:
	return await icon_loader.get_cached_badges(channel_id);

## Gets the requested emotes.
## Key: EmoteID as String ; Value: SpriteFrame
func get_emotes(ids: Array[String]) -> Dictionary:
	return await icon_loader.get_emotes(ids);

## Gets the requested emotes in the specified theme, scale and type.
## Loads from cache if possible otherwise downloads and transforms them.
## Key: TwitchEmoteDefinition ; Value SpriteFrames
func get_emotes_by_definition(emotes: Array[TwitchEmoteDefinition]) -> Dictionary:
	return await icon_loader.get_emotes_by_definition(emotes);

## Get the requested badges. (valid scale values are 1,2,3)
## Loads from cache if possible otherwise downloads and transforms them.
## Key: Badge Composite ; Value: SpriteFrames
func get_badges(badge: Array[String], channel_id: String = "global", scale: int = 1) -> Dictionary:
	return await icon_loader.get_badges(badge, channel_id);

func _init_cheermotes() -> void:
	cheer_repository = await TwitchCheerRepository.new(api, main);

## Returns the complete parsed data out of a cheer word.
func get_cheer_tier(cheer_word: String,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> TwitchCheerRepository.CheerResult:
	return await cheer_repository.get_cheer_tier(cheer_word, theme, type, scale);

## Returns the data of the Cheermotes.
func get_cheermote_data() -> Array[TwitchCheermote]:
	await cheer_repository.wait_is_ready();
	return cheer_repository.data;

## Checks if a prefix is existing.
func is_cheermote_prefix_existing(prefix: String) -> bool:
	return cheer_repository.is_cheermote_prefix_existing(prefix);

## Returns all cheertiers in form of:
## Key: TwitchCheermote.Tiers ; Value: SpriteFrames
func get_cheermotes(cheermote: TwitchCheermote,
	theme: TwitchCheerRepository.Themes = TwitchCheerRepository.Themes.DARK,
	type: TwitchCheerRepository.Types = TwitchCheerRepository.Types.ANIMATED,
	scale: TwitchCheerRepository.Scales = TwitchCheerRepository.Scales._1) -> Dictionary:
	return await cheer_repository.get_cheermotes(cheermote, theme, type, scale);

func add_command(command: String, callback: Callable, args_min: int = 0, args_max: int = -1,
	permission_level : TwitchCommandHandler.PermissionFlag = TwitchCommandHandler.PermissionFlag.EVERYONE,
	where : TwitchCommandHandler.WhereFlag = TwitchCommandHandler.WhereFlag.CHAT) -> void:

	log.i("Register command %s" % command)
	commands.add_command(command, callback, args_min, args_max, permission_level, where);

func remove_command(command: String) -> void:
	log.i("Remove command %s" % command)
	commands.remove_command(command);

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

func get_live_streamers_data(user_names_or_ids : Array = []) -> Dictionary:
	if not is_connected_to_twitch:
		return {}
	
	if user_names_or_ids.is_empty():
		for key in main.globals.known_users.keys():
			var user : RSTwitchUser = main.globals.known_users[key]
			if user.get("is_streamer") != null:
				if user.is_streamer:
					user_names_or_ids.append(key)
			else:
				print("user %s doesn't have is_streamer??"%user.username)
	
	var live_streamers_data := {}
	var max_user_query = 10
	while not user_names_or_ids.is_empty():
		var names : Array[String] = []
		var ids : Array[String] = []
		var count = 0
		for i in range(user_names_or_ids.size()-1, -1, -1):
			var user_name_id = user_names_or_ids[i]
			user_names_or_ids.remove_at(i)
			if user_name_id is String:
				names.append(user_name_id)
			elif user_name_id is int:
				ids.append(str(user_name_id))
			
			if count > max_user_query:
				var res := await api.get_streams(ids, names, [], "", [], 0, "", "")
				res
				for stream : TwitchStream in res.data:
					live_streamers_data[stream.user_login] = stream
				break
			count += 1
	
	return live_streamers_data


func raid(to_broadcaster_id : String):
	var path = "/helix/raids?from_broadcaster_id={from}&to_broadcaster_id={to}".format(
		{"from": str(main.settings.broadcaster_id),
		"to":to_broadcaster_id})
	var response = await api.request(path, HTTPClient.METHOD_POST, "", "application/x-www-form-urlencoded");
	response.response_code
