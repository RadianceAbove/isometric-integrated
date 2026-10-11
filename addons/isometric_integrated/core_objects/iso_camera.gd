class_name IsoCamera extends Camera3D
## A camera for rendering isometric pixel art.
##
## The [IsoCamera] node functions as an isometric camera when placed as a 
## descendant of an [IsoWorld] node. Its rotation is locked to an isometric
## perspective, and should be placed as a child of an [IsoCameraHandle] or have
## its position snapped to the grid of an [IsoWorld] via 
## [method IsoWorld.snap_to_position] in order to ensure consistent rendering 
## alignment.

## The world the [IsoCamera] is contained in and will render to.
var world : IsoWorld

## The clone of the [IsoCamera], used by [IsoWorld] to track object ids at
## screenspace locations.
var clone : IsoCameraClone


## A node shadowing the movements of an [IsoCamera].
##
## An [IsoCameraClone] is linked to an [IsoCamera] via its 
## [member IsoCameraClone.clone] property, and will copy the global position of
## that camera. It is used by an [IsoWorld] to track the id of the foremost 
## object at any given pixel.
class IsoCameraClone extends Camera3D:
	## The [IsoCamera] to copy.
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
	world.add_clone(clone)
