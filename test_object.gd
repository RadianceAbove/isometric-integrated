extends IsoObjectNew




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("move_up"):
		#camera.translate_object_local(Vector3(0,move_dist,0))
		#camera_clone.translate_object_local(Vector3(0,move_dist,0))
		global_translate(Vector3(0,world.pixel_widths.y/2,0))
		#obj_clone.global_translate(Vector3(0,translate_dist_y,0))
	elif Input.is_action_just_pressed("move_down"):
		#camera.translate_object_local(Vector3(0,-1*move_dist,0))
		#camera_clone.translate_object_local(Vector3(0,-1*move_dist,0))
		global_translate(Vector3(0,-world.pixel_widths.y/2,0))
		#obj_clone.global_translate(Vector3(0,-translate_dist_y,0))
	elif Input.is_action_just_pressed("move_left"):
		global_translate(Vector3(world.pixel_widths.x/2,0,0))
		#obj_clone.global_translate(Vector3(translate_dist_x,0,0))
	elif Input.is_action_just_pressed("move_right"):
		global_translate(Vector3(-world.pixel_widths.x/2,0,0))
		#obj_clone.global_translate(Vector3(-translate_dist_x,0,0))
	elif Input.is_action_just_pressed("move_vert_up"):
		global_translate(Vector3(0,0,world.pixel_widths.z/2))
		#obj_clone.global_translate(Vector3(0,0,translate_dist_z))
	elif Input.is_action_just_pressed("move_vert_down"):
		global_translate(Vector3(0,0,-world.pixel_widths.z/2))
		#obj_clone.global_translate(Vector3(0,0,-translate_dist_z))
