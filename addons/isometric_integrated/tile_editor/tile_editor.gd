extends Control

@onready var selector : TabContainer = self.find_child("TileSelector")
@onready var world : IsoWorld = self.find_child("IsoWorld")
@onready var viewer : TextureRect = self.find_child("IsoViewer")
var preview_node : IsoObject

@export var tile_x : int = 16
@export var tile_y : int = 32
@export var tile_z : int = 16


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preview_node = IsoObject.new()
	preview_node.tile = selector.current_selection
	world.add_child(preview_node)
	selector.tile_changed.connect(_selection_changed)
	viewer.gui_input.connect(_on_viewer_input)

func _selection_changed(tile : IsoTile) -> void:
	preview_node.set_tile(tile)

func _lock_to_grid(position : Vector3i) -> Vector3i:
	var x := snappedi(position.x,tile_x)
	var y := snappedi(position.y,tile_y)
	var z := snappedi(position.z,tile_z)
	return Vector3i(x,y,z)

func _on_viewer_input(event : InputEvent) -> void:
	if event.is_action_pressed("mouse_button_left"):
		var obj := IsoObject.new()
		obj.tile = preview_node.tile
		obj.position = preview_node.position
		world.add_child(obj)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	preview_node.position = _lock_to_grid(viewer.get_z_level_pos_at_position(get_local_mouse_position(),0))
	
