@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCreateStreamMarkerBody

## The ID of the broadcaster that’s streaming content. This ID must match the user ID in the access token or the user in the access token must be one of the broadcaster’s editors.
var user_id: String;
## A short description of the marker to help the user remember why they marked the location. The maximum length of the description is 140 characters.
var description: String;

static func from_json(d: Dictionary) -> TwitchCreateStreamMarkerBody:
	var result = TwitchCreateStreamMarkerBody.new();
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("description") && d["description"] != null:
		result.description = d["description"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["user_id"] = user_id;
	d["description"] = description;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

