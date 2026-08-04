class_name IsoViewer extends TextureRect

@export var camera : IsoCamera
@export var world : IsoWorld
var test_shader_file = preload("res://compute_example_2.glsl")
var compute_worker_prefab = preload("res://iso_compute_worker.tscn")
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
	
	test_compute()

func get_tile_array() -> Array[Array]:
	var tiles : Array[Array] = []
	for obj in world.solid_iso_nodes:
		tiles.append_array(obj.get_tiles())
	return tiles

func test_compute() -> void:
	
	# Create a local rendering device.
	var rd := RenderingServer.create_local_rendering_device()
	# Load GLSL shader
	var shader_file := load("res://compute_example.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	# Prepare our data. We use floats in the shader, so we need 32 bit.
	var input := PackedFloat32Array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
	var input_bytes := input.to_byte_array()

	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	var uniform_set := rd.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 5, 1, 1)
	rd.compute_list_end()
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync()
	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(buffer)
	var output := output_bytes.to_float32_array()
	print("Input: ", input)
	print("Output: ", output)

func get_pixel_at_position(pos : Vector2) -> IsoObject.IsoPixel:
	var uv = pos/size
	var camera_pos = floor(uv * Vector2(camera.get_size()))
	return camera.get_camera_pixel(camera_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	compute_worker.set_uniform_data_by_alias(Image.create_empty(camera.width,camera.height,false,Image.FORMAT_RGBAF),"im",1,false)
	compute_worker.set_uniform_data_by_alias(camera.position,"camera_pos",0,false)
	compute_worker.set_uniform_data_by_alias(camera.cull_distance,"cull_distance",0,false)
	compute_worker.set_uniform_data_by_alias(world.solid_iso_nodes.size(),"tile_count",0,false)
	compute_worker.set_uniform_data_by_alias(get_tile_array(),"tile_arr",0,true)
	
	texture = ImageTexture.create_from_image(compute_worker.get_uniform_data_by_alias("im",1))
