@tool
extends Control


var main : RSMain

func _ready():
	set_process(false)

func start():
	if !main.copilot.flags_changed.is_connected(update_ck_buttons):
		main.copilot.flags_changed.connect(update_ck_buttons)
	%pnl_copilot_settings.visible = false
	set_process(false)
	update_ck_buttons()


func update_ck_buttons():
	%ck_copilot.button_pressed = main.copilot.is_enabled
	play_alert(main.copilot.is_enabled)
	%progress_time_left.max_value = main.copilot.active_timer.wait_time
	%progress_time_left.visible = main.copilot.is_enabled
	set_process(main.copilot.is_enabled)
	
	%ck_code.button_pressed = main.copilot.code_active
	%ck_replace.button_pressed = main.copilot.replace_active
	%ck_goto.button_pressed = main.copilot.goto_active
	%ck_enter.button_pressed = main.copilot.enter_active
	%ck_erase.button_pressed = main.copilot.erase_active
	%ck_indent.button_pressed = main.copilot.indent_active
	%ck_shift.button_pressed = main.copilot.shift_active
	%ck_undo.button_pressed = main.copilot.undo_active


func _process(delta):
	%progress_time_left.value = main.copilot.active_timer.time_left

func play_alert(val : bool):
	%light.visible = val
	if val: %anim.play("alert")
	else: %anim.stop()


func _on_ck_code_toggled(toggled_on):
	if main.copilot.code_active != toggled_on:
		main.copilot.code_active = toggled_on
func _on_ck_replace_toggled(toggled_on):
	if main.copilot.replace_active != toggled_on:
		main.copilot.replace_active = toggled_on
func _on_ck_goto_toggled(toggled_on):
	if main.copilot.goto_active != toggled_on:
		main.copilot.goto_active = toggled_on
func _on_ck_enter_toggled(toggled_on):
	if main.copilot.enter_active != toggled_on:
		main.copilot.enter_active = toggled_on
func _on_ck_erase_toggled(toggled_on):
	if main.copilot.erase_active != toggled_on:
		main.copilot.erase_active = toggled_on
func _on_ck_indent_toggled(toggled_on):
	if main.copilot.indent_active != toggled_on:
		main.copilot.indent_active = toggled_on
func _on_ck_shift_toggled(toggled_on):
	if main.copilot.shift_active != toggled_on:
		main.copilot.shift_active = toggled_on
func _on_ck_undo_toggled(toggled_on):
	if main.copilot.undo_active != toggled_on:
		main.copilot.undo_active = toggled_on


func _on_ck_copilot_toggled(toggled_on):
	if main.copilot.is_enabled != toggled_on:
		%progress_time_left.visible = toggled_on
		if toggled_on:
			main.copilot.activate(600)
			%progress_time_left.max_value = main.copilot.active_timer.wait_time
		else:
			main.copilot.is_enabled = toggled_on
		set_process(toggled_on)

func _on_btn_expand_pressed():
	%pnl_copilot_settings.visible = !%pnl_copilot_settings.visible



