extends RefCounted
class_name RSVetting

var user_vetting_list : Array = []

var main : RSMain
var log : RSLogger

func start():
	log = RSLogger.new(RSSettings.LOGGER_NAME_VETTING)


func custom_rewards_vetting(callable : Callable, args: Array = []):
	
	pass


func load_user_vetting_list():
	var path = RSExternalLoader.get_config_path() + RSGlobals.rs_vetting_file_name
	if FileAccess.file_exists(path):
		user_vetting_list = main.loader.load_json(path)
func save_user_vetting_list():
	var path = RSExternalLoader.get_config_path() + RSGlobals.rs_vetting_file_name
	main.loader.save_to_json(path, user_vetting_list)
