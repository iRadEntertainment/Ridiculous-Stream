extends Control

@onready var center = %center
@onready var wheel_angle = %wheel_angle
@onready var selected_winner = %selected_winner
@onready var list = %list



@export var users = ["vex667", "dev_spaius", "pandacoder", "practicalNPC"]
@export_range(100, 512, 1) var radius : int = 256
@export var tot_res : int = 60 #points in full circle

func _ready():
	build_sectors()

func _process(_delta):
	center.rotation = center.position.angle_to_point(get_global_mouse_position())
	wheel_angle.text = "%d"%(rad_to_deg(center.rotation))
	var selected_index = floor((-center.rotation/TAU) * users.size() )
	selected_winner.text = users[selected_index]


func build_sectors():
	for child in center.get_children():
		child.queue_free()
	
	@warning_ignore("integer_division")
	var sector_res = tot_res/users.size()
	var angle_sector = TAU/users.size()
	var angle_res = angle_sector/sector_res
	
	var i= 0
	for user in users:
		var angle_init = i*angle_sector
		var points = [Vector2()]
		for j in sector_res + 1:
			var angle = angle_init + angle_res * j
			var p = Vector2.from_angle(angle) * radius
			points.append(p)
		
		var new_poly := Polygon2D.new()
		new_poly.polygon = points
		new_poly.color = Color(randf(), randf(), randf())
		center.add_child(new_poly)
		
		var lb := Label.new()
		lb.text = user
		lb.rotation = angle_init + angle_sector/2
		lb.position = Vector2.from_angle(lb.rotation) * 150
		new_poly.add_child(lb)
		
		i+=1


func _on_list_text_changed():
	users.clear()
	for i in list.get_line_count():
		users.append(list.get_line(i))
	
	build_sectors()
