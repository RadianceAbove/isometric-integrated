class_name IsoCamera extends Camera3D

var world : IsoWorld

var clone : IsoCameraClone


class IsoCameraClone extends Camera3D:
	var clone : IsoCamera
	
	func _ready() -> void:
		projection = clone.projection
		global_transform = clone.global_transform
		
		size = clone.size
		keep_aspect = clone.keep_aspect
	
	func _process(_delta: float) -> void:
		global_transform = clone.global_transform
		size = clone.size
		global_position = clone.world.snap_position(global_position)

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	rotation = Vector3(deg_to_rad(-30),0,0)
	
	# Return quietly if world is not yet set
	world = IsoWorld.get_world(self)
	if world == null:
		push_warning("An IsoCamera was added to the tree without a parent IsoWorld. It must be initialized manually.")
		return
	
	size = float(world.size.y) / world.pixels_per_unit
	keep_aspect = Camera3D.KEEP_HEIGHT
	
	clone = IsoCameraClone.new()
	clone.clone = self
	world.clone_list.append(clone)
