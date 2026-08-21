extends TabContainer

@export var tile_categories : Array[IsoTileEditorCategory]
var category_tag_preset = preload("res://addons/isometric_integrated/tile_editor/category_tab.tscn")
var current_selection : IsoTile = null
signal tile_changed (tile : IsoTile)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var default_set := false
	for category in tile_categories:
		var tab : TabBar = category_tag_preset.instantiate()
		tab.category = category
		add_child(tab)
		tab.tile_selected.connect(_on_tile_selected)
		if not default_set and not category.tiles.is_empty():
			current_selection = category.tiles[0]
			default_set = true

func _on_tile_selected(tile : IsoTile) -> void:
	if tile != current_selection:
		current_selection = tile
		tile_changed.emit(tile)
