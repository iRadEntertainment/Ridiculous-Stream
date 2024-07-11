@tool
extends RefCounted

class_name RSLogger

var context_name: String
var suffix: String
var enabled : bool
var debug: bool

func _init(_context_name: String) -> void:
	context_name = _context_name

func is_enabled() -> bool:
	return RSSettings.is_log_enabled(context_name)

func set_enabled(status: bool) -> void:
	enabled = status

func set_suffix(s: String) -> void:
	suffix = "-" + s

## log a message on info level
func i(text: String):
	if is_enabled(): print_rich("[%s%s] %s" % [context_name, suffix, text])

## log a message on error level
func e(text: String):
	if is_enabled(): printerr("[%s%s] %s" % [context_name, suffix, text])

## log a message on warning level
func w(text: String):
	if is_enabled(): print_rich("[color=yellow][%s%s] %s[/color]" % [context_name, suffix, text])

## log a message on debug level
func d(text: String):
	if is_enabled() && debug: print("[%s%s] %s" % [context_name, suffix, text])
