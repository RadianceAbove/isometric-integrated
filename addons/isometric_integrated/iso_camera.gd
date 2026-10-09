class_name IsoCamera extends Camera3D

@export var world : IsoWorld

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
	
	size = float(world.size.y) / world.pixels_per_unit
	keep_aspect = Camera3D.KEEP_HEIGHT
	
	clone = IsoCameraClone.new()
	clone.clone = self
	world.id_world.add_child(clone)
	

# Lock camera movement to ensure consistent display.
func _process(_delta: float) -> void:
	
	position = world.snap_position(position)
