@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchEventSubSubscription

## An ID that identifies the subscription.
var id: String;
## The subscription's status. The subscriber receives events only for **enabled** subscriptions. Possible values are:      * enabled — The subscription is enabled. * webhook\_callback\_verification\_pending — The subscription is pending verification of the specified callback URL. * webhook\_callback\_verification\_failed — The specified callback URL failed verification. * notification\_failures\_exceeded — The notification delivery failure rate was too high. * authorization\_revoked — The authorization was revoked for one or more users specified in the **Condition** object. * moderator\_removed — The moderator that authorized the subscription is no longer one of the broadcaster's moderators. * user\_removed — One of the users specified in the **Condition** object was removed. * version\_removed — The subscription to subscription type and version is no longer supported. * beta\_maintenance — The subscription to the beta subscription type was removed due to maintenance. * websocket\_disconnected — The client closed the connection. * websocket\_failed\_ping\_pong — The client failed to respond to a ping message. * websocket\_received\_inbound\_traffic — The client sent a non-pong message. Clients may only send pong messages (and only in response to a ping message). * websocket\_connection\_unused — The client failed to subscribe to events within the required time. * websocket\_internal\_error — The Twitch WebSocket server experienced an unexpected error. * websocket\_network\_timeout — The Twitch WebSocket server timed out writing the message to the client. * websocket\_network\_error — The Twitch WebSocket server experienced a network error writing the message to the client.
var status: String;
## The subscription's type. See [Subscription Types](https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types#subscription-types).
var type: String;
## The version number that identifies this definition of the subscription's data.
var version: String;
## The subscription's parameter values. This is a string-encoded JSON object whose contents are determined by the subscription type.
var condition: Dictionary;
## The date and time (in RFC3339 format) of when the subscription was created.
var created_at: Variant;
## The transport details used to send the notifications.
var transport: Transport;
## The amount that the subscription counts against your limit. [Learn More](https://dev.twitch.tv/docs/eventsub/manage-subscriptions/#subscription-limits)
var cost: int;

static func from_json(d: Dictionary) -> TwitchEventSubSubscription:
	var result = TwitchEventSubSubscription.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("status") && d["status"] != null:
		result.status = d["status"];
	if d.has("type") && d["type"] != null:
		result.type = d["type"];
	if d.has("version") && d["version"] != null:
		result.version = d["version"];
	if d.has("condition") && d["condition"] != null:
		result.condition = d["condition"];
	if d.has("created_at") && d["created_at"] != null:
		result.created_at = d["created_at"];
	if d.has("transport") && d["transport"] != null:
		result.transport = Transport.from_json(d["transport"]);
	if d.has("cost") && d["cost"] != null:
		result.cost = d["cost"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["status"] = status;
	d["type"] = type;
	d["version"] = version;
	d["condition"] = condition;
	d["created_at"] = created_at;
	if transport != null:
		d["transport"] = transport.to_dict();
	d["cost"] = cost;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## The transport details used to send the notifications.
class Transport extends RefCounted:
	## The transport method. Possible values are:      * webhook * websocket
	var method: String;
	## The callback URL where the notifications are sent. Included only if `method` is set to **webhook**.
	var callback: String;
	## An ID that identifies the WebSocket that notifications are sent to. Included only if `method` is set to **websocket**.
	var session_id: String;
	## The UTC date and time that the WebSocket connection was established. Included only if `method` is set to **websocket**.
	var connected_at: Variant;
	## The UTC date and time that the WebSocket connection was lost. Included only if `method` is set to **websocket**.
	var disconnected_at: Variant;


	static func from_json(d: Dictionary) -> Transport:
		var result = Transport.new();
		if d.has("method") && d["method"] != null:
			result.method = d["method"];
		if d.has("callback") && d["callback"] != null:
			result.callback = d["callback"];
		if d.has("session_id") && d["session_id"] != null:
			result.session_id = d["session_id"];
		if d.has("connected_at") && d["connected_at"] != null:
			result.connected_at = d["connected_at"];
		if d.has("disconnected_at") && d["disconnected_at"] != null:
			result.disconnected_at = d["disconnected_at"];
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["method"] = method;
		d["callback"] = callback;
		d["session_id"] = session_id;
		d["connected_at"] = connected_at;
		d["disconnected_at"] = disconnected_at;
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

