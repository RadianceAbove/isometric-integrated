class_name IsoWorld extends IsoNode

@export var ambient_light : Color = Color.BLACK
@export var solid_iso_nodes : Array[IsoObject]
@export var light_nodes : Array[IsoLight]
@export var max_nodes = 512
@export var max_lights = 512


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Set up world tiles.
	pass
	
	
func refresh_collection() -> void:
	solid_iso_nodes.clear()
	light_nodes.clear()
	_refresh_from_node(self)

func _refresh_from_node(node : IsoNode) -> void:
	if node is IsoObject:
		solid_iso_nodes.append(node)
	if node is IsoLight:
		light_nodes.append(node)
	for child in node.get_children():
		if child is IsoNode:
			_refresh_from_node(child)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	refresh_collection()
