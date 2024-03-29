@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchExtensionBitsProduct

## The product's SKU. The SKU is unique across an extension's products.
var sku: String;
## An object that contains the product's cost information.
var cost: Cost;
## A Boolean value that indicates whether the product is in development. If **true**, the product is not available for public use.
var in_development: bool;
## The product's name as displayed in the extension.
var display_name: String;
## The date and time, in RFC3339 format, when the product expires.
var expiration: Variant;
## A Boolean value that determines whether Bits product purchase events are broadcast to all instances of an extension on a channel. The events are broadcast via the `onTransactionComplete` helper callback. Is **true** if the event is broadcast to all instances.
var is_broadcast: bool;

static func from_json(d: Dictionary) -> TwitchExtensionBitsProduct:
	var result = TwitchExtensionBitsProduct.new();
	if d.has("sku") && d["sku"] != null:
		result.sku = d["sku"];
	if d.has("cost") && d["cost"] != null:
		result.cost = Cost.from_json(d["cost"]);
	if d.has("in_development") && d["in_development"] != null:
		result.in_development = d["in_development"];
	if d.has("display_name") && d["display_name"] != null:
		result.display_name = d["display_name"];
	if d.has("expiration") && d["expiration"] != null:
		result.expiration = d["expiration"];
	if d.has("is_broadcast") && d["is_broadcast"] != null:
		result.is_broadcast = d["is_broadcast"];
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["sku"] = sku;
	if cost != null:
		d["cost"] = cost.to_dict();
	d["in_development"] = in_development;
	d["display_name"] = display_name;
	d["expiration"] = expiration;
	d["is_broadcast"] = is_broadcast;
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the product's cost information.
class Cost extends RefCounted:
	## The product's price.
	var amount: int;
	## The type of currency. Possible values are:      * bits
	var type: String;


	static func from_json(d: Dictionary) -> Cost:
		var result = Cost.new();
		if d.has("amount") && d["amount"] != null:
			result.amount = d["amount"];
		if d.has("type") && d["type"] != null:
			result.type = d["type"];
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["amount"] = amount;
		d["type"] = type;
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

