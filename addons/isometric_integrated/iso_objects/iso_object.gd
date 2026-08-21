class_name IsoObject extends IsoNode

@export var tile : IsoTile
var base_image : Image
var layer_image : Image
var normal_image : Image

var solid_points : Array[IsoPixel]
var visible_points : Array[IsoPixel]
var _points_cache : Array[Array] = []
var _point_bounds_start = Vector3i.ZERO
var _point_bounds_end = Vector3i.ZERO
var _point_colors : PackedVector4Array
var _point_coords : PackedVector4Array
var _point_normals : PackedVector4Array

class IsoPixel:
	var parent : IsoObject
	var position : Vector3i
	var screenspace_offset : Vector2i
	var color : Color

func translate(vector : Vector3i) -> void:
	position += vector
	#for point in solid_points:
	#	point.position += vector
	if get_parent() is IsoNode:
		get_parent().update_bounds()

func build_point_bounds() -> void:
	for point in solid_points:
		_point_bounds_start = Vector3i( min(_point_bounds_start.x,point.position.x),\
										min(_point_bounds_start.y,point.position.y),\
										min(_point_bounds_start.z,point.position.z))
		_point_bounds_end = Vector3i(   max(_point_bounds_end.x,point.position.x),\
										max(_point_bounds_end.y,point.position.y),\
										max(_point_bounds_end.z,point.position.z))

func update_bounds() -> void:
	super()
	bounds_start = Vector3i(min(bounds_start.x,_point_bounds_start.x),\
							min(bounds_start.y,_point_bounds_start.y),\
							min(bounds_start.z,_point_bounds_start.z))
	bounds_end = Vector3i  (max(bounds_end.x,_point_bounds_end.x),\
							max(bounds_end.y,_point_bounds_end.y),\
							max(bounds_end.z,_point_bounds_end.z))

func color_to_normal_vec(color : Color) -> Vector3:
	var x = (color.r-.5)*2
	var y = (color.g-.5)*2
	var z = (color.b-.5)*2
	var out = Vector3(x,y,z)
	return out*color.a

func normal_vec_to_color(vector : Vector3) -> Color:
	var r = vector.x/2+.5
	var g = vector.y/2+.5
	var b = vector.z/2+.5
	var un_normed := Vector3(r,g,b)
	var a = un_normed.length()
	var normed = un_normed.normalized()
	return Color(normed.x,normed.y,normed.z,a)

func _ready() -> void:
	set_tile(tile)

func set_tile(new_tile : IsoTile):
	tile = new_tile
	base_image = tile.base_texture.get_image()
	layer_image = tile.layer_texture.get_image()
	normal_image = tile.normal_texture.get_image()
	_points_cache.resize(base_image.get_width())
	_point_coords.resize(base_image.get_width()*base_image.get_height())
	_point_colors.resize(base_image.get_width()*base_image.get_height())
	_point_normals.resize(base_image.get_width()*base_image.get_height())
	for a in range(_points_cache.size()):
		_points_cache[a] = []
		_points_cache[a].resize(base_image.get_height())
		_points_cache[a].fill(null)
	for x in range(layer_image.get_width()):
		for y in range(layer_image.get_height()):
			#print("x: " + str(x))
			#print("y: " + str(y))
			#if x==1 and y==24:
				#print("Break")
			var col : Color = base_image.get_pixel(x,y)
			if not is_zero_approx(col.a):
				var pos = get_pixel_pos(Vector2i(x,y))
				var point = IsoPixel.new()
				point.parent = self
				point.position = pos
				point.color = col
				point.screenspace_offset = Vector2i(x,y) - tile.origin_texture_coords
				visible_points.append(point)
				solid_points.append(point)
				_points_cache[x][y] = point
				# Get norm in global coordinates
				var norm := color_to_normal_vec(normal_image.get_pixel(x,y))
				var global_norm := norm
				# Leave x coord
				global_norm.y = norm.y / 2 - norm.z*(sqrt(3)/2)
				
				global_norm.z = norm.y * (sqrt(3)/2) + norm.z/2
				_point_colors[x+y*base_image.get_width()] = Vector4(col.r,col.g,col.b,col.a)
				_point_coords[x+y*base_image.get_width()] = Vector4(pos.x,pos.y,pos.z,0)
				
				_point_normals[x+y*base_image.get_width()] = Vector4(global_norm.x,global_norm.y,global_norm.z,0)
#				include_in_bounds(pos)
			else:
				_point_colors[x+y*base_image.get_width()] = Vector4(0,0,0,0)
				
	build_point_bounds()
	update_bounds()

func get_pixel_z(pixel : Vector2i) -> int:
	var col : Color = layer_image.get_pixelv(pixel)
	# use white as the top layer
	var z_offset : int = round(col.v * tile.layer_count)-1
	return z_offset - tile.origin_layer

func get_pixel_pos(pixel : Vector2i) -> Vector3i:
	var z = get_pixel_z(pixel)
	var x = pixel.x - tile.origin_texture_coords.x 
	var y = tile.origin_texture_coords.y - (z - tile.origin_layer) - pixel.y
	
	# y scales twice as fast as x does
	y *= 2
	return Vector3i(x,y,z) #+ get_global_position()

# Get a pixel aligned in screen space with the given position
func get_screenspace_pixels(pos : Vector3i) -> Array[IsoPixel]:
	var arr = super(pos)
	var screenspace_pos = Vector2i(pos.x,floor(float(pos.y)/2)+pos.z)
	var screenspace_origin = Vector2i(position.x,floor(float(position.y)/2)+position.z)
	var screenspace_offset = screenspace_pos-screenspace_origin
	var texture_pos = Vector2i(screenspace_offset.x,- screenspace_offset.y)\
					 + tile.origin_texture_coords
	if 0 <= texture_pos.x and texture_pos.x < base_image.get_width() and \
		0 <= texture_pos.y and texture_pos.y < base_image.get_height():
		var p = _points_cache[texture_pos.x][texture_pos.y]
		if not p == null:
			arr.append(p)
	return arr

func intersects_point(point : Vector3i):
	if not bounds_contain_point(point):
		return false
	
	for p in solid_points:
		if p.position == point:
			return true
	
	for child in get_children():
		if child is IsoNode:
			if child.intersects_point(point):
				return true
	return false

func line_intersections(start : Vector3i, end : Vector3i) -> Array[IsoPixel]:
	var arr : Array[IsoPixel] = []
	if not bounds_intersect_line(start, end):
		return arr
	
	for p in solid_points:
		var coords : Vector3i = p.position
		if point_intersects_view_line(start,end,p.position):
			if not (coords == start or coords == end):
				arr.append(p)
	
	for child in get_children():
		if child is IsoNode:
			arr.append_array(child.intersects_line(start,end))
	
	return arr
	

func get_tiles() -> Array:
	var global_pos = get_global_position()
	var out : Array = []
	
	out.append([])
	out[0].append(global_pos)
	out[0].append(Vector3i(tile.origin_texture_coords.x,tile.origin_texture_coords.y,0))
	out[0].append(_point_bounds_start)
	out[0].append(_point_bounds_end)
	out[0].append(_point_colors)
	out[0].append(_point_coords)
	out[0].append(_point_normals)
	
	return out
	
