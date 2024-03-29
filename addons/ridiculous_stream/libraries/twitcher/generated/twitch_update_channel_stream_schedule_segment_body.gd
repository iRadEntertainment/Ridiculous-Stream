@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchUpdateChannelStreamScheduleSegmentBody

## The date and time that the broadcast segment starts. Specify the date and time in RFC3339 format (for example, 2022-08-02T06:00:00Z).      **NOTE**: Only partners and affiliates may update a broadcast’s start time and only for non-recurring segments.
var start_time: Variant;
## The length of time, in minutes, that the broadcast is scheduled to run. The duration must be in the range 30 through 1380 (23 hours).
var duration: String;
## The ID of the category that best represents the broadcast’s content. To get the category ID, use the [Search Categories](https://dev.twitch.tv/docs/api/reference#search-categories) endpoint.
var category_id: String;
## The broadcast’s title. The title may contain a maximum of 140 characters.
var title: String;
## A Boolean value that indicates whether the broadcast is canceled. Set to **true** to cancel the segment.      **NOTE**: For recurring segments, the API cancels the first segment after the current UTC date and time and not the specified segment (unless the specified segment is the next segment after the current UTC date and time).
var is_canceled: bool;
## The time zone where the broadcast takes place. Specify the time zone using [IANA time zone database](https://www.iana.org/time-zones) format (for example, America/New\_York).
var timezone: String;

static func from_json(d: Dictionary) -> TwitchUpdateChannelStreamScheduleSegmentBody:
	var result = TwitchUpdateChannelStreamScheduleSegmentBody.new();
	if d.has("start_time") && d["start_time"] != null:
		result.start_time = d["start_time"];
	if d.has("duration") && d["duration"] != null:
		result.duration = d["duration"];
	if d.has("category_id") && d["category_id"] != null:
		result.category_id = d["category_id"];
	if d.has("title") && d["title"] != null:
		result.title = d["title"];
	if d.has("is_canceled") && d["is_canceled"] != null:
		result.is_canceled = d["is_canceled"];
	if d.has("timezone") && d["timezone"] != null:
		result.timezone = d["timezone"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["start_time"] = start_time;
	d["duration"] = duration;
	d["category_id"] = category_id;
	d["title"] = title;
	d["is_canceled"] = is_canceled;
	d["timezone"] = timezone;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

