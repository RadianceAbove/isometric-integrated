class_name IsoNode extends Node

@export var position : Vector3i = Vector3i.ZERO

var bounds_start : Vector3i = Vector3i.ZERO
var bounds_end : Vector3i = Vector3i.ZERO

class IsoPoint:
	var parent : IsoNode
	var position : Vector3i
	var color : Color

func get_global_position() -> Vector3i:
	var parent : Node = get_parent()
	if parent is IsoNode:
		return parent.position + position
	return position

func get_relative_position(base : IsoNode) -> Vector3i:
	return get_global_position() - base.get_global_position()

func update_bounds() -> void:
	var start = Vector3i.ZERO
	var end = Vector3i.ZERO
	for child in get_children():
		if child is IsoNode:
			start = Vector3i(min(child.bounds_start.x+child.position.x,start.x),\
								min(child.bounds_start.y+child.position.y,start.y),\
								min(child.bounds_start.z+child.position.z,start.z))
			end = Vector3i(  max(child.bounds_end.x+child.position.x,end.x),\
								max(child.bounds_end.y+child.position.y,end.y),\
								max(child.bounds_end.z+child.position.z,end.z))
	if start != bounds_start or end != bounds_end:
		bounds_start = start
		bounds_end = end
		if get_parent() is IsoNode:
			get_parent().update_bounds()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_bounds()

func bounds_contain_point(point : Vector3i) -> bool:
	var pos = get_global_position()
	return bounds_start.x + pos.x <= point.x and \
			bounds_start.y + pos.y <= point.y and \
			bounds_start.z + pos.z <= point.z and \
			bounds_end.x + pos.x >= point.x and \
			bounds_end.y + pos.y >= point.y and \
			bounds_end.z + pos.z >= point.z

# input in global coordinates
func bounds_intersect_line(start : Vector3i, end : Vector3i, \
							b_start : Vector3i = bounds_start, \
							b_end : Vector3i = bounds_end) -> bool:
	#first convert to local coordinates
	var pos = get_global_position()
	start -= pos
	end -= pos
	# Check if it intersects the bounding box through parameterization
	var t_start : float = -INF
	var t_end : float = INF
	if end.x-start.x == 0:
		if not (b_start.x <= end.x and end.x <= b_end.x or\
				b_end.x <= end.x and end.x <= b_start.x):
			return false
	else:
		var i_1 = float(b_start.x - start.x)/float(end.x-start.x)
		var i_2 = float(b_end.x - start.x)/float(end.x-start.x)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
		
	if end.y-start.y == 0:
		if not (b_start.y <= end.y and end.y <= b_end.y or\
				b_end.y <= end.y and end.y <= b_start.y):
			return false
	else:
		var i_1 = float(b_start.y - start.y)/float(end.y-start.y)
		var i_2 = float(b_end.y - start.y)/float(end.y-start.y)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
	
	if end.z-start.z == 0:
		if not (b_start.z <= end.z and end.z <= b_end.z or\
				b_end.z <= end.z and end.z <= b_start.z):
			return false
	else:
		var i_1 = float(b_start.z - start.z)/float(end.z-start.z)
		var i_2 = float(b_end.z - start.z)/float(end.z-start.z)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
	
	if t_end < t_start:
		return false
	else:
		return true

func point_intersects_view_line(start : Vector3i, end : Vector3i, point : Vector3i) -> bool:
	# Check if it intersects the bounding box through parameterization
	var t_start : float = -INF
	var t_end : float = INF
	var b_start : Vector3i = point
	var b_end : Vector3i = point + Vector3i(1,2,0)
	if end.x-start.x == 0:
		if not (b_start.x <= end.x and end.x < b_end.x or\
				b_end.x <= end.x and end.x < b_start.x):
			return false
	else:
		var i_1 = float(b_start.x - start.x)/float(end.x-start.x)
		var i_2 = float(b_end.x - start.x)/float(end.x-start.x)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
		
	if end.y-start.y == 0:
		if not (b_start.y <= end.y and end.y < b_end.y or\
				b_end.y <= end.y and end.y < b_start.y):
			return false
	else:
		var i_1 = float(b_start.y - start.y)/float(end.y-start.y)
		var i_2 = float(b_end.y - start.y)/float(end.y-start.y)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
	
	if end.z-start.z == 0:
		if not (b_start.z <= end.z and end.z <= b_end.z or\
				b_end.z <= end.z and end.z <= b_start.z):
			return false
	else:
		var i_1 = float(b_start.z - start.z)/float(end.z-start.z)
		var i_2 = float(b_end.z - start.z)/float(end.z-start.z)
		t_start = max(t_start,min(i_1,i_2))
		t_end = min(t_end, max(i_1,i_2))
	
	if t_end < t_start:
		return false
	elif t_end == t_start and is_equal_approx(start.y+float(t_start)*float(end.y-start.y),float(b_end.y)):
		return false
	elif t_end == t_start and is_equal_approx(start.x+float(t_start)*float(end.x-start.x),float(b_end.x)):
		return false
	else:
		return true

func intersects_point(point : Vector3i) -> bool:
	if bounds_contain_point(point):
		for child in get_children():
			if child is IsoNode:
				if child.intersects_point(point-child.position):
					return true
	return false

func line_intersections(start : Vector3i, end : Vector3i) -> Array[IsoObject.IsoPixel]:
	var arr : Array[IsoObject.IsoPixel] = []
	if not bounds_intersect_line(start, end):
		return arr
	
	for child in get_children():
		if child is IsoNode:
			arr.append_array(child.line_intersections(start-child.position,end-child.position))
	
	return arr

func get_screenspace_pixels(pos : Vector3i) -> Array[IsoObject.IsoPixel]:
	var arr : Array[IsoObject.IsoPixel]= []
	if not(bounds_start.x <= pos.x and pos.x <= bounds_end.x):
		return arr
	var screenspace_pos = Vector2i(pos.x,floor(float(pos.y)/2)+pos.z)
	if not(float(bounds_start.y)/2+bounds_start.z <= screenspace_pos.y and \
			screenspace_pos.y <= float(bounds_end.y)/2+bounds_end.z):
		return arr
	for child in get_children():
		if child is IsoNode:
			arr.append_array(child.get_screenspace_pixels(pos))
	return arr
