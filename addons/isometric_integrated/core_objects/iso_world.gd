class_name IsoWorld extends Node3D
## Base object of an isometric world
##
## The [IsoWorld] node controls functions as the container for all isometric
## rendering. All Iso nodes must have an [IsoWorld] as an anscestor to appear
## correctly. At runtime, the [IsoWorld] will create two [SubViewport]s to
## render the isometric nodes within it.

# Keep track of used ids in sequence
var _next_valid_id : int = 1
# Track all objects currently in the IsoWorld
var _objects_dict : Dictionary[int, IsoObject]
# Keep an image of the correct size to avoid reconstructing an image each frame.
var _current_image : Image

## The [Subviewport] containing all Iso nodes to be rendered.
var view_world : SubViewport

## The [Subviewport] containing clones of Iso nodes in the [member view_world]. 
## Under normal operation, the clones shadow nodes in the [member view_world].
var id_world : SubViewport

## The size in pixels of the [IsoWorld]'s output.
@export var size : Vector2i = Vector2i(512,512)

## The [IsoCamera] the [IsoWorld] will render from.
@export var active_camera : IsoCamera

## The target [TextureRect] the [IsoWorld] will output its rendered image to.
@export var display : TextureRect

## The background color if no object is rendered.
@export var background_color : Color = Color(0.25, 0.25, 0.25, 1.0)

## The [World3D] environment to use in the [SubViewport] rendering.
@export var world_3d : World3D

# Keep track of clones to place into the id_world once it is created.
var _clone_list : Array[Node3D] = []

## The number of pixels shown per godot world unit.
@export var pixels_per_unit : int = 32:
	set(value):
		pixels_per_unit = value
		var x_dist : float = 1.0 / value
		var y_dist : float = sqrt(3)* (2.0/3) / value
		var z_dist = 2.0 / value
		pixel_widths = Vector3(x_dist,y_dist,z_dist)

## The width of a displayed pixel in worldspace along each axis.
var pixel_widths : Vector3 = Vector3(1.0/32,sqrt(3)*(2.0/3)/32.0,2.0/32)


## Get the closest ancestor [IsoWorld] of a given node, or [code]null[/code] if  
## it is not the descendant of an [IsoWorld].
static func get_world(node : Node) -> IsoWorld:
	var p = node.get_parent()
	while p is not IsoWorld and p != null:
		p = p.get_parent()
	return p


## Get a valid id for a new [IsoObject].
func get_valid_id() -> int:
	while _objects_dict.get(_next_valid_id) != null:
		_next_valid_id += 1 
	var out = _next_valid_id
	_next_valid_id += 1
	return out


## Add an [IsoObject] to the [IsoWorld]'s list of objects to render.
func index_object(object : IsoObject) -> void:
	_objects_dict[object.id] = object


## Index the clone of an Iso node to be added into the [IsoWorld]'s [member id_world]
## upon its creation. Use this only when the [IsoWorld] has not yet executed
## its [method _ready] method. Otherwise, use [method create_clone].
func add_clone(clone : Node3D) -> void:
	_clone_list.append(clone)


## Add a clone of an Iso node to the [member id_world] of the [IsoWorld].
func create_clone(clone : Node3D) -> void:
	id_world.add_child(clone)


## Snap a position to the pixel grid of the [IsoWorld].
func snap_position(pos : Vector3) -> Vector3:
	# Calculate values that will snap to the viewspace grid
	return pos.snapped(pixel_widths)


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
	for clone in _clone_list:
		create_clone(clone)
	
	_current_image = Image.create_empty(size.x,size.y,false,Image.FORMAT_RGBA8)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	await RenderingServer.frame_post_draw
	var id_im : Image = id_world.get_texture().get_image()
	var dif_im : Image = view_world.get_texture().get_image()
	for x in range(size.x):
		for y in range(size.y):
			var pix_col := background_color
			var id_col := id_im.get_pixel(x,y)
			var id : int = IsoObject.IsoObjectClone.color_to_id(id_col)
			var obj : IsoObject = _objects_dict.get(id)
			
			if obj != null and obj.tile != null:
				var obj_im : Image = obj.tile.image
				var origin : Vector2 = active_camera.unproject_position(obj.global_position)
				var origin_conv_x = roundi(origin.x) + obj.tile.texture_offset.x
				var origin_conv_y = roundi(origin.y) - obj.tile.texture_offset.y
				var tex_pos = Vector2(x,y)-Vector2(origin_conv_x,origin_conv_y)+.5*Vector2(obj_im.get_size())
				if 0 <= tex_pos.x and tex_pos.x < obj_im.get_size().x and 0 <= tex_pos.y and tex_pos.y < obj_im.get_size().y:
					pix_col = obj_im.get_pixelv(Vector2i(tex_pos))
				pix_col *= dif_im.get_pixel(x,y)
			
			_current_image.set_pixel(x,y,pix_col)
	
	display.texture = ImageTexture.create_from_image(_current_image)
	display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
