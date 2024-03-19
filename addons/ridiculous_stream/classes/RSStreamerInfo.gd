extends Resource
class_name RSStreamerInfo

var id : int
var user_id : int
var user_login : String
var user_name : String
var game_id : int
var game_name : String
var type : String
var title : String
var viewer_count : int
var started_at : Dictionary
var language : String
var thumbnail_url : String
var tag_ids : Array
var tags : Array
var is_mature : bool



func get_thumbnail_url(x : int = 640, y : int = 360) -> String:
	var url = thumbnail_url
	url = url.replace("{width}", str(x))
	url = url.replace("{height}", str(y))
	return url

static func from_data(data : Dictionary) -> RSStreamerInfo:
	var new_streamer_info := RSStreamerInfo.new()
	
	new_streamer_info.id = data.id as int
	new_streamer_info.user_id = data.user_id as int
	new_streamer_info.user_login = data.user_login
	new_streamer_info.user_name = data.user_name
	new_streamer_info.game_id = data.game_id as int
	new_streamer_info.game_name = data.game_name
	new_streamer_info.type = data.type
	new_streamer_info.title = data.title
	new_streamer_info.viewer_count = data.viewer_count as int
	new_streamer_info.started_at = Time.get_datetime_dict_from_datetime_string(data.started_at, false)
	new_streamer_info.language = data.language
	new_streamer_info.thumbnail_url = data.thumbnail_url
	new_streamer_info.tag_ids = data.tag_ids
	new_streamer_info.tags = data.tags
	new_streamer_info.is_mature = data.is_mature
	
	return new_streamer_info


#var example = {
	#"id": "50670727885",
	#"user_id": "30693918",
	#"user_login": "timbeaudet",
	#"user_name": "TimBeaudet",
	#"game_id": "1469308723",
	#"game_name": "Software and Game Development",
	#"type": "live",
	#"title": "🔴 Pro Game Developer, C++, Custom Engine, Prototyping 🏁 - 2177",
	#"viewer_count": 46,
	#"started_at": "2024-03-19T10:03:20Z",
	#"language": "en",
	#"thumbnail_url": "https://static-cdn.jtvnw.net/previews-ttv/live_user_timbeaudet-{width}x{height}.jpg",
	#"tag_ids": [],
	#"tags": ["GameDev", "GameDesign", "Racing", "English", "Planning", "Learning", "CPlusPlus", "SafeForWork", "FamilyFriendly", "JavaScript"],
	#"is_mature": false
	#}
