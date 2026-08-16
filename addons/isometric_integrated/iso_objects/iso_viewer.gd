class_name IsoViewer extends TextureRect

@export var camera : IsoCamera
@export var world : IsoWorld
var test_shader_file = preload("res://addons/isometric_integrated/shader/iso_view.glsl")
var compute_worker_prefab = preload("res://addons/isometric_integrated/shader/iso_compute_worker.tscn")
var compute_worker : ComputeWorker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = ImageTexture.new()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	compute_worker = compute_worker_prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	
	## Initialize GPU variables
	var camera_pos_uniform: GPU_Vector3i = compute_worker.get_uniform_by_alias("camera_pos")
	camera_pos_uniform.data = camera.position
	
	var cull_distance_uniform: GPU_Float = compute_worker.get_uniform_by_alias("cull_distance")
	cull_distance_uniform.data = float(camera.cull_distance)
	
	var tile_count_uniform: GPU_Integer = compute_worker.get_uniform_by_alias("tile_count")
	tile_count_uniform.data = world.solid_iso_nodes.size()
	
	compute_worker.get_uniform_by_alias("tile_arr").array_size = world.max_nodes
	compute_worker.get_uniform_by_alias("light_arr",2).array_size = world.max_lights
	
	
	#DEBUG VALUE
	var debug_uniform: GPU_Float = compute_worker.get_uniform_by_alias("debug_val", 3)
	debug_uniform.data = 0.0;
	
	#var tile_array: GPU_StructArray = compute_worker.get_uniform_by_alias("tile_arr")
	#var tiles_in := get_tile_array()
	#tile_array.data = tiles_in
	
	var im = Image.create_empty(camera.width,camera.height,false,Image.FORMAT_RGBAF)
	var im_uniform : GPU_Image = compute_worker.get_uniform_by_alias("im",1)
	im_uniform.data = im
	im_uniform.image_size = Vector2i(camera.width,camera.height)
	compute_worker.work_group_size = Vector3i(floor(float(camera.width)/8),floor(float(camera.height)/8),1)
	
	
	
	#var im_uniform: GPU_Texture2DArray = compute_worker.get_uniform_by_alias("im", 1)
	#im_uniform.data = im
	
	compute_worker.initialize()
	

func get_tile_array() -> Array[Array]:
	var tiles : Array[Array] = []
	for obj in world.solid_iso_nodes:
		tiles.append_array(obj.get_tiles())
	return tiles

func get_light_array() -> Array[Array]:
	var lights : Array[Array] = []
	for light in world.light_nodes:
		lights.append(light.get_data())
	return lights

func get_pixel_at_position(pos : Vector2) -> IsoObject.IsoPixel:
	var uv = pos/size
	var camera_pos = floor(uv * Vector2(camera.get_size()))
	return camera.get_camera_pixel(camera_pos)

func get_pixel_color_at_position(pos : Vector2) -> Color:
	var uv := pos/size
	var camera_pos = floor(uv * Vector2(camera.get_size()))
	var im : Image = texture.get_image()
	if im != null:
		if 0 <= camera_pos.x and camera_pos.x < camera.get_size().x and 0 <= camera_pos.y and camera_pos.y < camera.get_size().y:
			return im.get_pixel(camera_pos.x,camera_pos.y)
	return Color.RED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	compute_worker.set_uniform_data_by_alias(Image.create_empty(camera.width,camera.height,false,Image.FORMAT_RGBAF),"im",1,false)
	compute_worker.set_uniform_data_by_alias(camera.position,"camera_pos",0,false)
	compute_worker.set_uniform_data_by_alias(camera.cull_distance,"cull_distance",0,false)
	compute_worker.set_uniform_data_by_alias(world.solid_iso_nodes.size(),"tile_count",0,false)
	compute_worker.set_uniform_data_by_alias(get_tile_array(),"tile_arr",0,false)
	compute_worker.set_uniform_data_by_alias(world.light_nodes.size(),"light_count",2,false)
	compute_worker.set_uniform_data_by_alias(get_light_array(),"light_arr",2,true)
	
	texture = ImageTexture.create_from_image(compute_worker.get_uniform_data_by_alias("im",1))
	#print(compute_worker.get_uniform_data_by_alias("debug_val",3))
