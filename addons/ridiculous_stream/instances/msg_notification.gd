# notification wave
@tool
extends Node2D

var main : RSMain
var duration = 1.5
var username : String = ""

func _ready():
	set_process(false)

func play():
	set_process(true)
	var hashed = hash(username)
	var assigned_num := (hashed % 11) as int
	var sound_path = "sfx_notification_%02d.ogg"%[assigned_num]
	if username in main.known_users.keys():
		var user := main.known_users[username] as RSTwitchUser
		if !user.custom_notification_sfx.is_empty():
			sound_path = user.custom_notification_sfx
	
	$sfx.stream = main.loader.load_sfx_from_sfx_folder(sound_path)
	$sfx.play()
	$part.emitting = true


var dt := 0.0
func _process(d):
	dt += d
	if dt > 3.0:
		queue_free()





