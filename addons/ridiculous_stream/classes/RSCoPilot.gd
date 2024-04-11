@tool
extends Node
class_name RSCoPilot

var main : RSMain
enum Cmd{HELP, CODE, REPLACE, GOTO, ENTER, ERASE, INDENT, UNINDENT, SHIFT_UP, SHIFT_DOWN, UNDO}

var is_enabled := false : set = set_is_enabled
var active_timer : Timer

var code_active := true : set = set_code_active
var replace_active := true : set = set_replace_active
var goto_active := true : set = set_goto_active
var enter_active := true : set = set_enter_active
var erase_active := true : set = set_erase_active
var indent_active := true : set = set_indent_active
var shift_active := true : set = set_shift_active
var undo_active := true : set = set_undo_active

signal flags_changed

#var cursor_assign = {
	#"code_editor" : null,
	#"carets": {
		#"username" : 012,
	#}
#}

func start():
	add_commands()
	active_timer = Timer.new()
	active_timer.one_shot = true
	active_timer.wait_time = 10
	active_timer.timeout.connect(_on_active_timer_timeout)
	add_child(active_timer)

func add_commands() -> void:
	main.twitcher.commands.add_command("copilot", copilot_action.bind(Cmd.HELP))
	main.twitcher.commands.add_command("code", copilot_action.bind(Cmd.CODE), 1)
	main.twitcher.commands.add_command("replace", copilot_action.bind(Cmd.REPLACE), 1)
	main.twitcher.commands.add_command("goto", copilot_action.bind(Cmd.GOTO), 1, 1)
	main.twitcher.commands.add_command("enter", copilot_action.bind(Cmd.ENTER))
	main.twitcher.commands.add_command("erase", copilot_action.bind(Cmd.ERASE))
	main.twitcher.commands.add_command("indent", copilot_action.bind(Cmd.INDENT))
	main.twitcher.commands.add_command("unindent", copilot_action.bind(Cmd.UNINDENT))
	main.twitcher.commands.add_command("shiftup", copilot_action.bind(Cmd.SHIFT_UP))
	main.twitcher.commands.add_command("shiftdown", copilot_action.bind(Cmd.SHIFT_DOWN))
	main.twitcher.commands.add_command("undo", copilot_action.bind(Cmd.UNDO))


func temp_activate():
	activate(300)

func copilot_action(info: TwitchCommandInfo, arg_ary, what := Cmd.HELP):
	if not is_enabled:
		main.twitcher.chat("Co-pilot is turned off")
		return
	
	var editor_script := EditorInterface.get_script_editor().get_current_editor()
	if not editor_script:
		print("There is no code editor to code to!")
		return
	var code_edit := editor_script.get_base_editor() as CodeEdit
	var current_line = code_edit.get_caret_line()
	
	if !verify_command_is_active(what):
		var msg = "%s is not active!"%[Cmd.keys()[what]]
		main.twitcher.chat(msg)
		return
	
	match what:
		Cmd.HELP:
			var msg = "use these !commands to co-pilot: code, replace, goto, enter, erase, indent, unindent, shiftup, shiftdown" 
			main.twitcher.chat(msg)
		Cmd.CODE: compose_code_message(arg_ary, code_edit, current_line, false)
		Cmd.REPLACE: compose_code_message(arg_ary, code_edit, current_line, true)
		Cmd.GOTO:
			var goto_line_num = int(arg_ary[0]) -1
			code_edit.set_caret_line(goto_line_num)
		Cmd.ENTER:
			code_edit.insert_line_at(current_line+1, "")
			code_edit.set_caret_line(current_line+1)
		Cmd.ERASE:
			var line_is_empty = code_edit.get_line(current_line) == ""
			if line_is_empty:
				code_edit.backspace()
			else:
				code_edit.set_line(current_line, "")
		Cmd.INDENT: code_edit.indent_lines()
		Cmd.UNINDENT: code_edit.unindent_lines()
		Cmd.SHIFT_UP: code_edit.swap_lines(current_line, current_line-1)
		Cmd.SHIFT_DOWN: code_edit.swap_lines(current_line, current_line+1)
		Cmd.UNDO: code_edit.undo()


func verify_command_is_active(what) -> bool:
	match what:
		Cmd.CODE: if !code_active: return false
		Cmd.REPLACE:  if !replace_active: return false
		Cmd.GOTO: if !goto_active: return false
		Cmd.ENTER: if !enter_active: return false
		Cmd.ERASE: if !erase_active: return false
		Cmd.INDENT: if !indent_active: return false
		Cmd.UNINDENT: if !indent_active: return false
		Cmd.SHIFT_UP: if !shift_active: return false
		Cmd.SHIFT_DOWN: if !shift_active: return false
		Cmd.UNDO: if !undo_active: return false
	return true


func compose_code_message(arg_ary : PackedStringArray, code_edit : CodeEdit, current_line : int, replace := false):
	var msg = ""
	# --- parse indentation
	var add_tabs = 0
	for i in arg_ary.size():
		if i == 0:
			if arg_ary[0].find("*") != -1:
				add_tabs = arg_ary[0].count("*")
				continue
		msg += arg_ary[i]
		msg += " "
	
	msg = msg.strip_edges()
	
	# --- editing lines
	if current_line == code_edit.get_line_count()-1:
		code_edit.insert_line_at(current_line, "")
	if not replace:
		var at_line = current_line
		if code_edit.get_line(current_line) != "": at_line = current_line + 1
		code_edit.insert_line_at(at_line, msg)
		code_edit.set_caret_line(current_line + 1)
	else:
		code_edit.set_line(current_line, msg)
	
	# --- indentation
	for tab in add_tabs:
		code_edit.indent_lines()


func activate(timeout_in_sec := 3.0):
	active_timer.wait_time = timeout_in_sec
	is_enabled = true
	active_timer.start()
func _on_active_timer_timeout():
	is_enabled = false
	flags_changed.emit()

func set_is_enabled(val):
	is_enabled = val
	flags_changed.emit()

func set_code_active(val):
	code_active = val
	flags_changed.emit()
func set_replace_active(val):
	replace_active = val
	flags_changed.emit()
func set_goto_active(val):
	goto_active = val
	flags_changed.emit()
func set_enter_active(val):
	enter_active = val
	flags_changed.emit()
func set_erase_active(val):
	erase_active = val
	flags_changed.emit()
func set_indent_active(val):
	indent_active = val
	flags_changed.emit()
func set_shift_active(val):
	shift_active = val
	flags_changed.emit()
func set_undo_active(val):
	undo_active = val
	flags_changed.emit()








