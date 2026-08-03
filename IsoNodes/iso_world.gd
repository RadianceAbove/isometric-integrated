class_name IsoWorld extends IsoNode

@export var solid_iso_nodes : Array[IsoObject]
var compute_prefab = preload("res://iso_compute_worker.tscn")
var compute_worker : ComputeWorker


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	compute_worker = compute_prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	
	# Set up world tiles.
	pass
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
