@tool
extends Window

var main : RSMain
@onready var pnl_settings = %pnl_settings

func start():
	pnl_settings.main = main
	pnl_settings.start()

func _on_close_requested():
	hide()
