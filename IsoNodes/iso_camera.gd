class_name IsoCamera extends IsoNode

@export var width : int = 512
@export var height : int = 512

@export var collection : IsoNode


# Caching shader vars
var shader : RID

func get_size() -> Vector2i:
	return Vector2i(width,height)

func get_camera_pixel(texture_pos : Vector2i) -> IsoObject.IsoPixel:
	var x = texture_pos.x
	var y = height - texture_pos.y - 1
	var start_offset = Vector3i(x-floor(float(width)/2),2*y-height,0)
	var relative = get_relative_position(collection)
	var z_depth = relative.z - collection.bounds_start.z
	var end_offset = start_offset - Vector3i(0,-2*z_depth,z_depth)
	var int_point = IsoRay.intersect_screenspace(collection,start_offset+relative)
	
	
	return int_point

func get_image() -> Image:
	var im : Image = Image.create_empty(width, height,false,Image.FORMAT_RGBA8)
	var lights = collection.find_children("*","IsoLight")
	var im_bytes : PackedColorArray = []
	var pos_bytes : PackedVector4Array = []
	
	for i in range(width):
		for j in range(height):
			var pix = get_camera_pixel(Vector2i(i,j))
			
			if not pix == null:
				var color : Color = pix.color
				#for light in lights:
				#	var ints = IsoRay.intersect(collection,pix.position,light.get_global_position())
				#	if ints == null:
				#		color.lerp(light.color,1)
				#		pix.position.distance_to(light.get_global_position())
				im.set_pixel(i,j,color)
				im_bytes.append(color)
				pos_bytes.append(Vector4(pix.position.x,pix.position.y,pix.position.z,1))
			else:
				im.set_pixel(i,j, Color.BLACK)
				im_bytes.append(Color.BLACK)
				pos_bytes.append(Vector4(get_global_position().x,get_global_position().y,get_global_position().z,1))
	
	# Create a local rendering device.
	var rd := RenderingServer.create_local_rendering_device()
	
	# Load GLSL shader
	var shader_file := load("res://IsoNodes/light_calc.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	var im_in := im_bytes.to_byte_array()
	var col_buffer :=rd.storage_buffer_create(im_in.size(),im_in)
	var col_unif := RDUniform.new()
	col_unif.add_id(col_buffer)
	col_unif.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	# Create a uniform to assign the buffer to the rendering device
	var col_unif_set := rd.uniform_set_create([col_unif], shader, 2) # the last parameter (the 0) needs to match the "set" in our shader file
	
	var pos_in := pos_bytes.to_byte_array()
	var pos_buffer :=rd.storage_buffer_create(pos_in.size(),pos_in)
	var pos_unif := RDUniform.new()
	pos_unif.add_id(pos_buffer)
	pos_unif.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	var pos_unif_set := rd.uniform_set_create([pos_unif], shader, 1) # the last parameter (the 0) needs to match the "set" in our shader file
	
	
	var size_bytes := PackedInt32Array([width,height])
	var size_in := size_bytes.to_byte_array()
	var size_buffer := rd.storage_buffer_create(size_in.size(),size_in)
	var size_unif := RDUniform.new()
	size_unif.add_id(size_buffer)
	size_unif.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	var size_unif_set := rd.uniform_set_create([size_unif], shader,0)
	
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, size_unif_set, 0)
	rd.compute_list_bind_uniform_set(compute_list, pos_unif_set, 1)
	rd.compute_list_bind_uniform_set(compute_list, col_unif_set, 2)
	rd.compute_list_dispatch(compute_list, width, height, 1)
	rd.compute_list_end()
	
	# Submit to GPU and wait for sync
	#rd.submit()
	#rd.sync()
	
	var output_bytes := rd.buffer_get_data(col_buffer)
	var output := output_bytes.to_color_array()
	rd.free_rid(col_unif_set)
	rd.free_rid(col_buffer)
	rd.free_rid(pos_unif_set)
	rd.free_rid(pos_buffer)
	rd.free_rid(size_unif_set)
	rd.free_rid(size_buffer)
	rd.free_rid(shader)
	rd.free()
	
	for i in range(width):
		for j in range(height):
			pass
			#im.set_pixel(i,j,output[height*i+j])
	
	return im

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
