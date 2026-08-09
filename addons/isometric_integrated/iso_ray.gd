class_name IsoRay extends Object


static func intersect(container : IsoNode, start : Vector3i, end : Vector3i) -> IsoObject.IsoPixel:
	#var arr : Array[IsoNode.IsoPoint] = container.line_intersections(start, end)
	var arr : Array[IsoObject.IsoPixel] = container.line_intersections(start,end)
	if arr.is_empty():
		return null
	var min_dist : float = INF
	#var min_int : IsoNode.IsoPoint = arr[0]
	var min_int = arr[0]
	for point in arr:
		var dist = start.distance_to(point.position)
		if dist < min_dist:
			min_dist = dist
			min_int = point
	return min_int

static func intersect_screenspace(container : IsoNode, pos : Vector3i) -> IsoObject.IsoPixel:
	#var arr : Array[IsoNode.IsoPoint] = container.line_intersections(start, end)
	var arr : Array[IsoObject.IsoPixel] = container.get_screenspace_pixels(pos)
	if arr.is_empty():
		return null
	var min_dist : float = INF
	#var min_int : IsoNode.IsoPoint = arr[0]
	var min_int = arr[0]
	for point in arr:
		var dist = pos.distance_to(point.position)
		if dist < min_dist:
			min_dist = dist
			min_int = point
	return min_int
