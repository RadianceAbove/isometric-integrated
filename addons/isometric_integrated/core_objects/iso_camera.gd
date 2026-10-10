class_name IsoCamera extends Camera3D

var world : IsoWorld

var clone : IsoCameraClone


class IsoCameraClone extends Camera3D:
	var clone : IsoCamera
	
	func _ready() -> void:
		projection = clone.projection
		transform = clone.transform
		
		size = clone.size
		keep_aspect = clone.keep_aspect
	
	func _process(_delta: float) -> void:
		global_transform = clone.global_transform
		size = clone.size
		position = clone.world.snap_position(position)

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	rotation = Vector3(deg_to_rad(-30),0,0)
	
	# Return quietly if world is not yet set
	if world == null:
		var p = get_parent()
		while p is not IsoWorld and p != null:
			p = p.get_parent()
		world = p
	if world is not IsoWorld:
		push_warning("An IsoCamera was added to the tree without a parent IsoWorld. It must be initialized manually.")
		return
	
	size = float(world.size.y) / world.pixels_per_unit
	keep_aspect = Camera3D.KEEP_HEIGHT
	
	clone = IsoCameraClone.new()
	clone.clone = self
	

# Lock camera movement to ensure consistent display.
func _process(_delta: float) -> void:
	
	position = world.snap_position(position)
