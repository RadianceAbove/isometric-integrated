extends IsoObject

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		global_translate(Vector3(0,0,-world.pixel_widths.z))
	elif Input.is_action_just_pressed("move_down"):
		global_translate(Vector3(0,0,world.pixel_widths.z))
	elif Input.is_action_just_pressed("move_left"):
		global_translate(Vector3(-world.pixel_widths.x,0,0))
	elif Input.is_action_just_pressed("move_right"):
		global_translate(Vector3(world.pixel_widths.x,0,0))
	elif Input.is_action_just_pressed("move_vert_up"):
		global_translate(Vector3(0,world.pixel_widths.y,0))
	elif Input.is_action_just_pressed("move_vert_down"):
		global_translate(Vector3(0,-world.pixel_widths.y,0))
