@tool
extends RefCounted

# CLASS GOT AUTOGENERATED DON'T CHANGE MANUALLY. CHANGES CAN BE OVERWRITTEN EASILY.

class_name TwitchCharityCampaignDonation

## An ID that identifies the donation. The ID is unique across campaigns.
var id: String;
## An ID that identifies the charity campaign that the donation applies to.
var campaign_id: String;
## An ID that identifies a user that donated money to the campaign.
var user_id: String;
## The user’s login name.
var user_login: String;
## The user’s display name.
var user_name: String;
## An object that contains the amount of money that the user donated.
var amount: Amount;

static func from_json(d: Dictionary) -> TwitchCharityCampaignDonation:
	var result = TwitchCharityCampaignDonation.new();
	if d.has("id") && d["id"] != null:
		result.id = d["id"];
	if d.has("campaign_id") && d["campaign_id"] != null:
		result.campaign_id = d["campaign_id"];
	if d.has("user_id") && d["user_id"] != null:
		result.user_id = d["user_id"];
	if d.has("user_login") && d["user_login"] != null:
		result.user_login = d["user_login"];
	if d.has("user_name") && d["user_name"] != null:
		result.user_name = d["user_name"];
	if d.has("amount") && d["amount"] != null:
		result.amount = Amount.from_json(d["amount"]);
	return result;

func to_dict() -> Dictionary:
	var d: Dictionary = {};
	d["id"] = id;
	d["campaign_id"] = campaign_id;
	d["user_id"] = user_id;
	d["user_login"] = user_login;
	d["user_name"] = user_name;
	if amount != null:
		d["amount"] = amount.to_dict();
	return d;

func to_json() -> String:
	return JSON.stringify(to_dict());

## An object that contains the amount of money that the user donated.
class Amount extends RefCounted:
	## The monetary amount. The amount is specified in the currency’s minor unit. For example, the minor units for USD is cents, so if the amount is $5.50 USD, `value` is set to 550.
	var value: int;
	## The number of decimal places used by the currency. For example, USD uses two decimal places. Use this number to translate `value` from minor units to major units by using the formula:      `value / 10^decimal_places`
	var decimal_places: int;
	## The ISO-4217 three-letter currency code that identifies the type of currency in `value`.
	var currency: String;


	static func from_json(d: Dictionary) -> Amount:
		var result = Amount.new();
		if d.has("value") && d["value"] != null:
			result.value = d["value"];
		if d.has("decimal_places") && d["decimal_places"] != null:
			result.decimal_places = d["decimal_places"];
		if d.has("currency") && d["currency"] != null:
			result.currency = d["currency"];
		return result;

	func to_dict() -> Dictionary:
		var d: Dictionary = {};
		d["value"] = value;
		d["decimal_places"] = decimal_places;
		d["currency"] = currency;
		return d;


	func to_json() -> String:
		return JSON.stringify(to_dict());

