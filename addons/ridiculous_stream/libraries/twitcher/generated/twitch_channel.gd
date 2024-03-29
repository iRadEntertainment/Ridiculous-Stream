@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchChannel

## The ISO 639-1 two-letter language code of the language used by the broadcaster. For example, _en_ for English. If the broadcaster uses a language not in the list of [supported stream languages](https://help.twitch.tv/s/article/languages-on-twitch#streamlang), the value is _other_.
var broadcaster_language: String;
## The broadcaster’s login name.
var broadcaster_login: String;
## The broadcaster’s display name.
var display_name: String;
## The ID of the game that the broadcaster is playing or last played.
var game_id: String;
## The name of the game that the broadcaster is playing or last played.
var game_name: String;
## An ID that uniquely identifies the channel (this is the broadcaster’s ID).
var id: String;
## A Boolean value that determines whether the broadcaster is streaming live. Is **true** if the broadcaster is streaming live; otherwise, **false**.
var is_live: bool;
## **IMPORTANT** As of February 28, 2023, this field is deprecated and returns only an empty array. If you use this field, please update your code to use the `tags` field.      The list of tags that apply to the stream. The list contains IDs only when the channel is steaming live. For a list of possible tags, see [List of All Tags](https://www.twitch.tv/directory/all/tags). The list doesn’t include Category Tags.
var tag_ids: Array[String];
## The tags applied to the channel.
var tags: Array[String];
## A URL to a thumbnail of the broadcaster’s profile image.
var thumbnail_url: String;
## The stream’s title. Is an empty string if the broadcaster didn’t set it.
var title: String;
## The UTC date and time (in RFC3339 format) of when the broadcaster started streaming. The string is empty if the broadcaster is not streaming live.
var started_at: Variant;

static func from_json(d: Dictionary) -> TwitchChannel:
	var result = TwitchChannel.new();
	if d.has("broadcaster_language") && d["broadcaster_language"] != null:
		result.broadcaster_language = d["broadcaster_language"];
	if d.has("broadcaster_login") && d["broadcaster_login"] != null:
		result.broadcaster_login = d["broadcaster_login"];
	if d.has("display_name") && d["display_name"] != null:
		result.display_name = d["display_name"];
	if d.has("game_id") && d["game_id"] != null:
		result.game_id = d["game_id"];
	if d.has("game_name") && d["game_name"] != null:
		result.game_name = d["game_name"];
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("is_live") && d["is_live"] != null:
		result.is_live = d["is_live"];
	if d.has("tag_ids") && d["tag_ids"] != null:
		for value in d["tag_ids"]:
			result.tag_ids.append(value);
	if d.has("tags") && d["tags"] != null:
		for value in d["tags"]:
			result.tags.append(value);
	if d.has("thumbnail_url") && d["thumbnail_url"] != null:
		result.thumbnail_url = d["thumbnail_url"];
	if d.has("title") && d["title"] != null:
		result.title = d["title"];
	if d.has("started_at") && d["started_at"] != null:
		result.started_at = d["started_at"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["broadcaster_language"] = broadcaster_language;
	d["broadcaster_login"] = broadcaster_login;
	d["display_name"] = display_name;
	d["game_id"] = game_id;
	d["game_name"] = game_name;
	d["id"] = id;
	d["is_live"] = is_live;
	d["tag_ids"] = [];
	if tag_ids != null:
		for value in tag_ids:
			d["tag_ids"].append(value);
	d["tags"] = [];
	if tags != null:
		for value in tags:
			d["tags"].append(value);
	d["thumbnail_url"] = thumbnail_url;
	d["title"] = title;
	d["started_at"] = started_at;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

