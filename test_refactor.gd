extends Node

@export var camera : Camera3D
@export var camera_clone : Camera3D
@export var objarray : Array[MeshInstance3D]
@export var ids : SubViewport
@export var world : SubViewport 
@export var tex : TextureRect
@export var obj_tex : CompressedTexture2D
@export var obj : Node3D
@export var obj_clone : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	
	
	var w = 128
	var h = 128
	var im : Image = Image.create_empty(w,h,false,Image.FORMAT_RGBA8)

	var id_im : Image = ids.get_texture().get_image()
	var dif_im : Image = world.get_texture().get_image()
	var obj_im := obj_tex.get_image()
	for x in range(w):
		for y in range(h):
			var x_conv = roundi((float(x)+.5)/w*id_im.get_size().x)
			var y_conv = roundi((float(y)+.5)/h*id_im.get_size().y)
			var col = id_im.get_pixel(x_conv,y_conv)
			im.set_pixel(x,y,col)
			if col == Color.RED:
				var origin := camera.unproject_position(objarray[0].position)
				var origin_conv_x = roundi(origin.x/world.size.x*w)
				var origin_conv_y = roundi(origin.y/world.size.y*h)
				var tex_pos = Vector2(x,y)-Vector2(origin_conv_x,origin_conv_y)+.5*Vector2(obj_im.get_size())
				if 0 <= tex_pos.x and tex_pos.x < obj_im.get_size().x and 0 <= tex_pos.y and tex_pos.y < obj_im.get_size().y:
					im.set_pixel(x,y,obj_im.get_pixelv(Vector2i(tex_pos)))
				if x == origin_conv_x and y == origin_conv_y:
					im.set_pixel(x,y,Color.BLACK)
			if col == Color.GREEN:
				var origin := camera.unproject_position(objarray[1].position)
				var origin_conv_x = roundi(origin.x/world.size.x*w)
				var origin_conv_y = roundi(origin.y/world.size.y*h)
				var tex_pos = Vector2(x,y)-Vector2(origin_conv_x,origin_conv_y)+.5*Vector2(obj_im.get_size())
				if 0 <= tex_pos.x and tex_pos.x < obj_im.get_size().x and 0 <= tex_pos.y and tex_pos.y < obj_im.get_size().y:
					im.set_pixel(x,y,obj_im.get_pixelv(Vector2i(tex_pos)))
			if col == Color.BLUE:
				var origin := camera.unproject_position(objarray[2].position)
				var origin_conv_x = roundi(origin.x/world.size.x*w)
				var origin_conv_y = roundi(origin.y/world.size.y*h)
				var tex_pos = Vector2(x,y)-Vector2(origin_conv_x,origin_conv_y)+.5*Vector2(obj_im.get_size())
				if 0 <= tex_pos.x and tex_pos.x < obj_im.get_size().x and 0 <= tex_pos.y and tex_pos.y < obj_im.get_size().y:
					im.set_pixel(x,y,obj_im.get_pixelv(Vector2i(tex_pos)))
			col = im.get_pixel(x,y)
			col *= dif_im.get_pixel(x_conv,y_conv)
			im.set_pixel(x,y,col)
	tex.texture = ImageTexture.create_from_image(im)
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# must lock camera to multiple of sqrt(2)/32 from (0,0) in screenspace
	
	var move_dist = .0441941738
	var translate_dist = .01
	if Input.is_action_just_pressed("move_up"):
		#camera.translate_object_local(Vector3(0,move_dist,0))
		#camera_clone.translate_object_local(Vector3(0,move_dist,0))
		obj.translate(Vector3(translate_dist,0,0))
		obj_clone.translate(Vector3(translate_dist,0,0))
	elif Input.is_action_just_pressed("move_down"):
		#camera.translate_object_local(Vector3(0,-1*move_dist,0))
		#camera_clone.translate_object_local(Vector3(0,-1*move_dist,0))
		obj.translate(Vector3(-translate_dist,0,0))
		obj_clone.translate(Vector3(-translate_dist,0,0))
	elif Input.is_action_just_pressed("move_left"):
		camera.translate_object_local(Vector3(move_dist,0,0))
		camera_clone.translate_object_local(Vector3(move_dist,0,0))
	elif Input.is_action_just_pressed("move_right"):
		camera.translate_object_local(Vector3(-move_dist,0,0))
		camera_clone.translate_object_local(Vector3(-move_dist,0,0))
	elif Input.is_action_just_pressed("move_vert_up"):
		camera.translate_object_local(Vector3(0,0,move_dist))
		camera_clone.translate_object_local(Vector3(0,0,move_dist))
	elif Input.is_action_just_pressed("move_vert_down"):
		camera.translate_object_local(Vector3(0,0,-move_dist))
		camera_clone.translate_object_local(Vector3(0,0,-move_dist))
