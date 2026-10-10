extends TabBar

var tile_display_preset : PackedScene = preload("res://addons/isometric_integrated/tile_editor/tile_editor_icon.tscn")
@onready var grid : GridContainer = self.get_child(0).get_child(0)
@export var category: IsoTileEditorCategory
signal tile_selected (tile : IsoTile)

func _ready() -> void:
	name = category.name
	for t in category.tiles:
		var icon : TextureRect = tile_display_preset.instantiate()
		icon.texture = t.texture
		icon.gui_input.connect(_on_tile_event.bind(t))
		grid.add_child(icon)

func _on_tile_event (event : InputEvent, tile : IsoTile):
	if event.is_action_pressed("mouse_button_left"):
		tile_selected.emit(tile)
