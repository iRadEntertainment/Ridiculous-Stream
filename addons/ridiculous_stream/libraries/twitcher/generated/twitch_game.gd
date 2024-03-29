@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchGame

## An ID that identifies the category or game.
var id: String;
## The category’s or game’s name.
var name: String;
## A URL to the category’s or game’s box art. You must replace the `{width}x{height}` placeholder with the size of image you want.
var box_art_url: String;
## The ID that [IGDB](https://www.igdb.com/) uses to identify this game. If the IGDB ID is not available to Twitch, this field is set to an empty string.
var igdb_id: String;

static func from_json(d: Dictionary) -> TwitchGame:
	var result = TwitchGame.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("name") && d["name"] != null:
		result.name = d["name"];
	if d.has("box_art_url") && d["box_art_url"] != null:
		result.box_art_url = d["box_art_url"];
	if d.has("igdb_id") && d["igdb_id"] != null:
		result.igdb_id = d["igdb_id"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["name"] = name;
	d["box_art_url"] = box_art_url;
	d["igdb_id"] = igdb_id;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

