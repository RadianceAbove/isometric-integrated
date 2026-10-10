class_name IsoCameraHandle extends Node3D

var world : IsoWorld

func _ready() -> void:
	world = IsoWorld.get_world(self)
	if world == null:
		push_warning("An IsoCameraHandle was added to the tree without a parent IsoWorld. It must be initialized manually.")
		return

func _process(delta: float) -> void:
	for child in get_children():
		if child is IsoCamera:
			child.global_position = world.snap_position(global_position)
