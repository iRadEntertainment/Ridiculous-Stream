@tool
extends Control
class_name RSPnlChat

const commands_string_format = {
	"ACTION": "[i]%s[/i]",
	"!rb": "[rainbow freq=1.0 sat=0.8 val=0.8]%s[/rainbow]",
	"!big" : "[font_size=64]%s[/font_size]",
	"!small" : "[font_size=12]%s[/font_size]",
	"!wave" : "[wave amp=50.0 freq=5.0 connect=1]%s[/wave]",
	"!hl" : "[bgcolor=#ff0000][color=#ffffff]%s[/color][/bgcolor]",
	"!pulse" : "[pulse freq=1.0 color=#ffffff40 ease=-2.0]%s[/pulse]",
	"!tornado" : "[tornado radius=10.0 freq=1.0 connected=1]%s[/tornado]",
	"!shake" : "[shake rate=20.0 level=5 connected=1]%s[/shake]",
	"!hd" : "[bgcolor=#21262e][color=#21262e]%s[/color][/bgcolor]",
	#"!fade" : "[fade start=%s length=%s]"%[msg_length, msg_length*4] + msg + "[/fade]"
}
var main : RSMain


func start():
	#if !main.gift_reloaded.is_connected(connect_gift):
		#!main.gift_reloaded.connect(connect_gift)
	connect_gift_signals()
	%pnl_connect_to_gift.main = main
	%pnl_connect_to_gift.start()


func connect_gift_signals():
	if !main.gift.chat_message.is_connected(on_chat):
		main.gift.chat_message.connect(on_chat)
func on_chat(senderdata : SenderData, msg : String):
	if not senderdata.tags.has("display-name"): return
	check_first_msg(senderdata)
	put_chat(senderdata, msg)

var fl_first_chat_message := true
func put_chat(senderdata : SenderData, msg : String):
	var badges : String = ""
	for badge in senderdata.tags["badges"].split(",", false):
		var result = await(main.gift.iconloader.get_badge(badge, senderdata.tags["room-id"]))
		badges += "[img=center]" + result.resource_path + "[/img] "
	var locations : Array = []
	if (senderdata.tags.has("emotes")):
		for emote in senderdata.tags["emotes"].split("/", false):
			var data : Array = emote.split(":")
			for d in data[1].split(","):
				var start_end = d.split("-")
				locations.append(TwitchIRC.EmoteLocation.new(data[0], int(start_end[0]), int(start_end[1])))
	locations.sort_custom(TwitchIRC.EmoteLocation.smaller)
	var offset = 0
	for loc in locations:
		var result = await(main.gift.iconloader.get_emote(loc.id))
		var emote_string = "[img=center]" + result.resource_path +"[/img]"
		msg = msg.substr(0, loc.start + offset) + emote_string + msg.substr(loc.end + offset + 1)
		offset += emote_string.length() + loc.start - loc.end - 1
	
	var bbcode = set_msg(senderdata, msg, badges)
	if !fl_first_chat_message:
		%lb_chat.newline()
	%lb_chat.append_text(bbcode)
	fl_first_chat_message = false
	
	
	# TODO remove extra lines when the chat grows toooooo big
	#while %lb_chat.get_line_count() > main.settings.max_messages_in_chat or false:
		#%lb_chat


func format_msg(key, _msg) -> String:
		_msg = _msg.replacen(key+" ", "")
		_msg = _msg.strip_edges()
		return commands_string_format[key]%_msg
func set_msg(data : SenderData, msg : String, badges : String) -> String:
	if msg.begins_with("ACTION"):
		msg = format_msg("ACTION", msg)
	for key in commands_string_format.keys():
		if msg.find(key) != -1: 
			msg = format_msg(key, msg)
	
	var username_col = RSGlobals.DEFAULT_RIGID_LABEL_COLOR if data.tags["color"].is_empty() else data.tags["color"]
	var colored_name = "[b][color="+ username_col + "]" + data.tags["display-name"] +"[/color][/b]: "
	var final = badges + colored_name + msg
	return final


func check_first_msg(senderdata : SenderData):
	var username = senderdata.user
	var display_name = senderdata.tags["display-name"]
	if not username in main.globals.first_session_message_username_list:
		main.globals.first_session_message_username_list.append(username)
		check_user_twitch_color(senderdata)
		
		# let the physic name appear in the editor
		var user := RSTwitchUser.new()
		if username in main.globals.known_users:
			user = main.globals.known_users[senderdata.user.to_lower()]
			if user.auto_shoutout:
				main.shoutout_mng.add_shoutout(user)
			if user.auto_shoutout:
				main.gift.announce(user)
		else:
			user.display_name = display_name
		main.custom.destructibles_names(user)
		
		# automatic shoutout for known twitch users


func check_user_twitch_color(senderdata : SenderData):
	if !senderdata.tags.has("color"):
		return
	var tw_col = senderdata.tags["color"]
	
	if senderdata.user in main.globals.known_users.keys():
		var user := main.globals.known_users[senderdata.user] as RSTwitchUser
		if user.twitch_chat_color == Color.BLACK:
			user.twitch_chat_color = tw_col
			main.loader.save_userfile(user)


func change_font_size(font_size : int):
	theme.set("RichTextLabel/font_sizes/bold_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/bold_italics_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/italics_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/mono_font_size", font_size)
	theme.set("RichTextLabel/font_sizes/normal_font_size", font_size)
func _on_ln_msg_text_submitted(new_text):
	main.gift.chat(new_text)
	%ln_msg.clear()


func _on_sl_font_size_value_changed(value):
	change_font_size(value as int)
	%lb_font_size.text = str(value)


func _on_btn_command_pressed():
	var msg = %ln_msg.text
	var send = SenderData.new(main.settings.channel, "", {})
	main.gift.cmd_handler.handle_command(send, msg)
	%ln_msg.text = ""



