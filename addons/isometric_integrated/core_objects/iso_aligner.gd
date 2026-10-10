class_name IsoAligner extends Node3D

var world : IsoWorld

func _ready() -> void:
	if world == null:
		var p = get_parent()
		while p is not IsoWorld and p != null:
			p = p.get_parent()
		world = p
	if world is not IsoWorld:
		push_warning("An IsoAligner was added to the tree without a parent IsoWorld. It must be initialized manually.")
		return

func _process(delta: float) -> void:
	var logical_root := get_parent() as Node3D
	if logical_root == null:
		return
	var snapped_transform := logical_root.global_transform
	snapped_transform.origin = world.snap_position(snapped_transform.origin)
	global_transform = snapped_transform
