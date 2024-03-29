@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateCustomRewardResponse

## The list contains the single reward that you updated.
var data: Array[TwitchCustomReward];

static func from_json(d: Dictionary) -> TwitchUpdateCustomRewardResponse:
	var result = TwitchUpdateCustomRewardResponse.new();
	if d.has("data") && d["data"] != null:
		for value in d["data"]:
			result.data.append(TwitchCustomReward.from_json(value));
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["data"] = [];
	if data != null:
		for value in data:
			d["data"].append(value.to_dict());
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

