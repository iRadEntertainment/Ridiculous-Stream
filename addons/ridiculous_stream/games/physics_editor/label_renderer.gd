@tool
extends SubViewport


func generate_text_rigidbody(text : String, col : Color):
	# texture
	$lb.text = text
	$lb.size = Vector2()
	$lb.set("theme_override_colors/font_color", col)
	
	var outline_off := Vector2(12, 0)
	var lb_size = $lb.get_rect().size + outline_off
	
	$lb.position = outline_off/2.0
	size = lb_size
	$lb.queue_redraw()
	await get_tree().process_frame
	
	# generate polygon and texture
	var poly_points = [Vector2(0,0), Vector2(lb_size.x, 0), Vector2(lb_size.x, lb_size.y), Vector2(0, lb_size.y)]
	var view_tex = get_texture() as ViewportTexture
	var tex : Texture2D = ImageTexture.create_from_image( view_tex.get_image() )
	
	var new_lb_body := RSGlobals.lb_body_pack.instantiate() as RigidBody2D
	new_lb_body.lb_size = lb_size
	new_lb_body.poly_points = poly_points
	new_lb_body.tex = tex
	
	return new_lb_body
	#add_rigid(new_lb_body, pos, linear_velocity, angular_velocity, true)
