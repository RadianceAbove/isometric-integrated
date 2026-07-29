class_name IsoWorld extends IsoNode

@export var world_tile_width : int = 32
@export var world_tile_height : int = 16
@export var world_width : int = 10
@export var world_height : int = 5
var world_contents_index : Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up world tiles.
	for x in range(world_width):
		world_contents_index.append_array([])
		for y in range(world_width):
			world_contents_index[x].append_array([])
			for z in range(world_height):
				world_contents_index[x][y].append_array([])
				
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
