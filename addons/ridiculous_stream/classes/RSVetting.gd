extends RefCounted
class_name RSVetting

var main : RSMain
var log : RSLogger

var user_vetting_list : Dictionary = {}
enum Responses{ACCEPT, ACCEPT_ALL, DECLINE, DECLINE_WARN, DECLINE_ALL}

signal notification_queued(callable : Callable, data: RSTwitchEventData, warnings: int)
signal list_updated

func start():
	log = RSLogger.new(RSSettings.LOGGER_NAME_VETTING)
	load_user_vetting_list()


func custom_rewards_vetting(callable : Callable, data : RSTwitchEventData):
	var user = data.username
	var title = data.reward_title
	if not is_allowed(data): return
	
	if user not in user_vetting_list:
		user_vetting_list[user] = {
				"warnings": 0,
				"rewards": {},
			}
	
	var warnings = user_vetting_list[user]["warnings"]
	
	if user_vetting_list[user]["rewards"].has(title):
		var status = user_vetting_list[user]["rewards"][title]
		match status:
			Responses.ACCEPT_ALL:
				log.i("Impersonate autoaccepted. [color=#f00]{user}: [color=#0f0]{msg}[/color]".format({"user": data.username, "msg": data.user_input}))
				callable.call(data)
			Responses.DECLINE_ALL:
				log.w("Impersonate blocked (user). {user}: {msg}".format({"user": data.username, "msg": data.user_input}))
				return
			_:
				log.i("Notification request pending...")
				notification_queued.emit(callable, data, warnings)
	else:
		log.i("Notification request pending...")
		notification_queued.emit(callable, data, warnings)


func is_allowed(data: RSTwitchEventData) -> bool:
	if "Impersonate" in data.reward_title:
		var broadcaster_login : String = data.user_input.split(" ", true, 1)[0]
		var allowed = broadcaster_login.to_lower() in main.known_users
		if allowed:
			log.i("Impersonate allowed ([color=#f00]{streamer}). {user}: {msg}".format({"streamer": broadcaster_login, "user": data.username, "msg": data.user_input}))
		else:
			log.w("Impersonate blocked (unknown broadcaster). {user}: {msg}".format({"user": data.username, "msg": data.user_input}))
		return allowed
		
	return true


func receive_response(callable : Callable, data: RSTwitchEventData, response: Responses) -> void:
	var user = data.username
	var title = data.reward_title
	
	log.i("Received response ({res}): {user}".format({
			"res": Responses.keys()[response],
			"user": data.username,
		}))
	
	match response:
		Responses.ACCEPT_ALL:
			user_vetting_list[user]["rewards"].merge({title: response}, true)
			callable.call(data)
			save_user_vetting_list()
			list_updated.emit()
		Responses.ACCEPT:
			callable.call(data)
		Responses.DECLINE_WARN:
			user_vetting_list[user]["warnings"] += 1
			save_user_vetting_list()
			list_updated.emit()
		Responses.DECLINE:
			pass
		Responses.DECLINE_ALL:
			user_vetting_list[user]["rewards"].merge({title: response}, true)
			save_user_vetting_list()
			list_updated.emit()
	


func load_user_vetting_list():
	var path = RSExternalLoader.get_config_path() + RSGlobals.rs_vetting_file_name
	if FileAccess.file_exists(path):
		log.i("List loaded (%s)" % path)
		user_vetting_list = main.loader.load_json(path)
func save_user_vetting_list():
	var path = RSExternalLoader.get_config_path() + RSGlobals.rs_vetting_file_name
	main.loader.save_to_json(path, user_vetting_list)
