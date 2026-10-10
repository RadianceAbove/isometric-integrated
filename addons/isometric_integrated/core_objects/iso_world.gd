class_name IsoWorld extends Node3D

var next_valid_id : int = 1
var objects_dict : Dictionary[int, IsoObject]
var view_world : SubViewport
var id_world : SubViewport
var current_image : Image
@export var size : Vector2i = Vector2i(512,512)
@export var world_3d : World3D

@export var active_camera : IsoCamera
@export var display : TextureRect
@export var neutral_color : Color = Color(0.25, 0.25, 0.25, 1.0)

@export var pixels_per_unit : int = 32:
	set(value):
		pixels_per_unit = value
		var x_dist : float = 1.0 / value
		var y_dist : float = sqrt(3)* (2.0/3) / value
		var z_dist = 2.0 / value
		pixel_widths = Vector3(x_dist,y_dist,z_dist)

# The width of pixels in worldspace
var pixel_widths : Vector3 = Vector3(1.0/32,sqrt(3)*(2.0/3)/32.0,2.0/32)

# Get a valid id for a new IsoObject
func get_valid_id() -> int:
	while objects_dict.get(next_valid_id) != null:
		next_valid_id += 1 
	var out = next_valid_id
	next_valid_id += 1
	return out

func index_object(object : IsoObject):
	objects_dict[object.id] = object

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var child_cache = get_children()
	view_world = SubViewport.new()
	add_child(view_world)
	view_world.size = size
	view_world.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	if world_3d != null:
		view_world.world_3d = world_3d
	
	id_world = SubViewport.new()
	add_child(id_world)
	id_world.size = size
	id_world.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	for child in child_cache:
		child.reparent(view_world)
		if child is IsoObject:
			id_world.add_child(child.clone)
		if child is IsoCamera:
			id_world.add_child(child.clone)
	
	
	
	current_image = Image.create_empty(size.x,size.y,false,Image.FORMAT_RGBA8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	await RenderingServer.frame_post_draw
	var id_im : Image = id_world.get_texture().get_image()
	var dif_im : Image = view_world.get_texture().get_image()
	for x in range(size.x):
		for y in range(size.y):
			var pix_col := neutral_color
			var id_col := id_im.get_pixel(x,y)
			var id : int = IsoObject.IdClone.color_to_id(id_col)
			var obj : IsoObject = objects_dict.get(id)
			if obj != null and obj.tile != null:
				var obj_im : Image = obj.tile.image
				var origin : Vector2 = active_camera.unproject_position(obj.position)
				var origin_conv_x = roundi(origin.x) + obj.tile.texture_offset.x
				var origin_conv_y = roundi(origin.y) - obj.tile.texture_offset.y
				var tex_pos = Vector2(x,y)-Vector2(origin_conv_x,origin_conv_y)+.5*Vector2(obj_im.get_size())
				if 0 <= tex_pos.x and tex_pos.x < obj_im.get_size().x and 0 <= tex_pos.y and tex_pos.y < obj_im.get_size().y:
					pix_col = obj_im.get_pixelv(Vector2i(tex_pos))
			
			pix_col *= dif_im.get_pixel(x,y)
			current_image.set_pixel(x,y,pix_col)
	
	display.texture = ImageTexture.create_from_image(current_image)
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func snap_position(pos : Vector3) -> Vector3:
	# Calculate values that will snap to the viewspace grid
	return pos.snapped(pixel_widths)
