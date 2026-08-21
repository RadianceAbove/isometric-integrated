extends Control

@onready var selector : TabContainer = self.find_child("TileSelector")
@onready var world : IsoWorld = self.find_child("IsoWorld")
@onready var viewer : IsoViewer = self.find_child("IsoViewer")
var preview_node : IsoObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preview_node = IsoObject.new()
	preview_node.tile = selector.current_selection
	world.add_child(preview_node)
	selector.tile_changed.connect(_selection_changed)
	

func _selection_changed(tile : IsoTile) -> void:
	preview_node.set_tile(tile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	preview_node.position = viewer.get_z_level_pos_at_position(get_local_mouse_position(),0)
