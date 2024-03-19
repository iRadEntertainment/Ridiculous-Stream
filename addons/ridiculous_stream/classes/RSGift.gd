@tool
@icon("res://addons/ridiculous_stream/ui/bootstrap_icons/gift-fill.svg")
extends Control
class_name RSGift

var main : RSMain

var id : TwitchIDConnection
var api : TwitchAPIConnection
var irc : TwitchIRCConnection
var eventsub : TwitchEventSubConnection
var cmd_handler : GIFTCommandHandler = GIFTCommandHandler.new()
var iconloader : TwitchIconDownloader

signal started
signal connected_to_twitch

# irc
signal whisper_message(sender_data, message)
signal chat_message(sender_data, message)
signal user_joined(sender_data)
signal user_parted(sender_data)
# api
signal channel_points_redeemed(RSTwitchEventData)
signal followed(RSTwitchEventData)
signal raided(RSTwitchEventData)
signal subscribed(RSTwitchEventData)
signal cheered(RSTwitchEventData)



var is_started := false
var is_connected_to_twitch := false
func start() -> void:
	is_started = true
	started.emit()
func start_connections() -> void:
	await auth()
	await update_streamer_id()
	await connect_to_irc()
	await connect_to_event_sub()
	connect_signals()
	is_connected_to_twitch = true
	connected_to_twitch.emit()


func update_streamer_id() -> int:
	var user_ids : Dictionary = await( api.get_users_by_name([main.settings.channel]) )
	main.settings.streamer_id = user_ids.data[0]["id"] as int
	return main.settings.streamer_id


func connect_signals():
	# TODO use frikinn lambda func please, this is so ugly
	irc.whisper_message.connect(emit_whisper_message)
	irc.chat_message.connect(emit_chat_message)
	irc.user_joined.connect(emit_user_joined)
	irc.user_parted.connect(emit_user_parted)
func emit_whisper_message(sender_data, message): whisper_message.emit(sender_data, message)
func emit_chat_message(sender_data, message): chat_message.emit(sender_data, message)
func emit_user_joined(sender_data): user_joined.emit(sender_data)
func emit_user_parted(sender_data): user_parted.emit(sender_data)


func auth():
	# We will login using the Implicit Grant Flow, which only requires a client_id.
	# Alternatively, you can use the Authorization Code Grant Flow or the Client Credentials Grant Flow.
	# Note that the Client Credentials Grant Flow will only return an AppAccessToken, which can not be used
	# for the majority of the Twitch API or to join a chat room.
	var auth : ImplicitGrantFlow = ImplicitGrantFlow.new()
	# For the auth to work, we need to poll it regularly.
	get_tree().process_frame.connect(auth.poll) # You can also use a timer if you don't want to poll on every frame.

	# Next, we actually get our token to authenticate. We want to be able to read and write messages,
	# so we request the required scopes. See https://dev.twitch.tv/docs/authentication/scopes/#twitch-access-token-scopes
	#print("Scope:\n", main.settings.scope)
	var scope := [
		RSGlobals.TwScope.CHAT_READ,
		RSGlobals.TwScope.CHAT_EDIT,
		RSGlobals.TwScope.SO,
		RSGlobals.TwScope.SUBS,
		RSGlobals.TwScope.FOLLOWERS,
		RSGlobals.TwScope.REDEMPTIONS,
		RSGlobals.TwScope.POLLS,
		RSGlobals.TwScope.RAIDS,
		RSGlobals.TwScope.BITS,
	]
	#scope = ["chat:read", "chat:edit"]
	#var token : UserAccessToken = await(auth.login(RSGlobals.client_id, main.settings.scope))
	var token : UserAccessToken = await(auth.login(RSGlobals.client_id, scope))
	assert(token != null, "Authentication failed. Abort.")
	
	# Store the token in the ID connection, create all other connections.
	id = TwitchIDConnection.new(token)
	irc = TwitchIRCConnection.new(id)
	api = TwitchAPIConnection.new(id)
	iconloader = TwitchIconDownloader.new(api)
	# For everything to work, the id connection has to be polled regularly.
	get_tree().process_frame.connect(id.poll)


func connect_to_irc():
	if(!await(irc.connect_to_irc(main.settings.channel))):
		# Authentication failed. Abort.
		return
	# Request the capabilities. By default only twitch.tv/commands and twitch.tv/tags are used.
	# Refer to https://dev.twitch.tv/docs/irc/capabilities/ for all available capabilities.
	irc.request_capabilities()
	irc.join_channel(main.settings.channel)
	
	# We also have to forward the messages to the command handler to handle them.
	irc.chat_message.connect(cmd_handler.handle_command)
	# If you also want to accept whispers, connect the signal and bind true as the last arg.
	irc.whisper_message.connect(cmd_handler.handle_command.bind(true))


func connect_to_event_sub():
	# This part of the example only works if GIFT is logged in to your broadcaster account.
	# If you are, you can uncomment this to also try receiving follow events.
	# Don't forget to also add the 'moderator:read:followers' scope to your token.
	eventsub = TwitchEventSubConnection.new(api)
	eventsub.event.connect(on_event)
	await(eventsub.connect_to_eventsub())
	
	eventsub.subscribe_event("channel.channel_points_custom_reward_redemption.add", "1", {"broadcaster_user_id": str(main.settings.streamer_id)})
	eventsub.subscribe_event("channel.raid", "1", {"to_broadcaster_user_id": str(main.settings.streamer_id)})
	eventsub.subscribe_event("channel.subscribe", "1", {"broadcaster_user_id": str(main.settings.streamer_id)})
	eventsub.subscribe_event("channel.cheer", "1", {"broadcaster_user_id": str(main.settings.streamer_id)})
	eventsub.subscribe_event("channel.follow", "2", {"broadcaster_user_id": str(main.settings.streamer_id), "moderator_user_id": str(main.settings.streamer_id)})


func on_event(type : String, body : Dictionary) -> void:
	var data := RSTwitchEventData.create_from_event_body(type, body)
	match(type):
		"channel.follow": followed.emit(data)
		"channel.channel_points_custom_reward_redemption.add": channel_points_redeemed.emit(data)
		"channel.raid": raided.emit(data)
		"channel.cheer": cheered.emit(data)
		"channel.subscribe": subscribed.emit(data)


func chat(msg : String) -> void:
	irc.chat(msg)


func announce(user : RSTwitchUser):
	irc.chat(user.promotion_description)


func send_shout_out_request(to_id : int):
	var url := "/helix/chat/shoutouts"
	var param = "?from_broadcaster_id=%s"%[main.settings.streamer_id]
	param += "&to_broadcaster_id=%s"%to_id
	param += "&moderator_id=%s"%[main.settings.streamer_id]
	var query = url + param
	var headers : PackedStringArray = [
		"Authorization: Bearer %s" % api.id_conn.last_token.token,
		"Client-Id: %s" % api.id_conn.last_token.last_client_id,
		"Content-Type: application/json"
	]
	var res = await api.request(HTTPClient.METHOD_POST, query, headers)


func start_raid(to_id : int):
	var url := "/helix/raids"
	var param = "?from_broadcaster_id=%s"%[main.settings.streamer_id]
	param += "&to_broadcaster_id=%s"%to_id
	var query = url + param
	var headers : PackedStringArray = [
		"Authorization: Bearer %s" % api.id_conn.last_token.token,
		"Client-Id: %s" % api.id_conn.last_token.last_client_id
	]
	var res = await api.request(HTTPClient.METHOD_POST, query, headers)


func get_live_streamers_data(user_names_or_ids : Array = main.globals.known_users.keys()) -> Dictionary:
	var url := "/helix/streams"
	var headers : PackedStringArray = [
		"Authorization: Bearer %s" % api.id_conn.last_token.token,
		"Client-Id: %s" % api.id_conn.last_token.last_client_id,
	]
	var param = ""
	
	var live_streamers_data := {}
	var first_iter := true
	
	var max_user_query = 50
	while not user_names_or_ids.is_empty():
		var count = 0
		for i in range(user_names_or_ids.size()-1, -1, -1):
			var user_name_id = user_names_or_ids[i]
			user_names_or_ids.remove_at(i)
			param += "?" if first_iter else "&"
			if user_name_id is String:
				param += "user_login=%s"%user_name_id
			elif user_name_id is int:
				param += "user_id=%s"%user_name_id
			first_iter = false
			if count > max_user_query:
				var query = url + param
				var response : Dictionary = await api.request(HTTPClient.METHOD_GET, query, headers)
				if !response.has("data"):
					break
				for data in response.data:
					if data.user_login == "coderadgames":
						print("YESSSSSS")
					live_streamers_data[data.user_login] = RSStreamerInfo.from_data(data)
				break
			count += 1
	
	return live_streamers_data


func gather_user_info(username : String) -> RSTwitchUser:
	var user = RSTwitchUser.new()
	var user_ids : Dictionary = await( api.get_users_by_name([username]) )
	if user_ids.data.is_empty(): return
	user.user_id = user_ids.data[0]["id"]
	user.display_name = user_ids.data[0]["display_name"]
	user.username = user_ids.data[0]["login"]
	user.profile_image_url = user_ids.data[0]["profile_image_url"]
	return user





