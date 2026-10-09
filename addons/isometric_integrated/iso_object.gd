class_name IsoObject extends MeshInstance3D

@export var texture : CompressedTexture2D :
	set(value):
		var s := value.get_size()
		if floori(s.x) % 2 != 0:
			push_warning("The width of an IsoObjectNew Texture must be even.")
			return
		if floori(s.y) % 2 != 0:
			push_warning("The height of an IsoObjectNew Texture must be even.")
			return
		image = value.get_image()
		texture = value

var image : Image

@export var texture_origin : Vector2i

@export var world : IsoWorld

var id_clone : MeshInstance3D = null
var id : int = 0
var id_color : Color = Color.BLACK

var clone : IdClone


# Clone object that shadows the movements of the IsoObjectNew for id depth
class IdClone extends MeshInstance3D:
	var clone : IsoObject
	var color : Color
	
	func _ready() -> void:
		mesh = clone.mesh
		global_transform = clone.global_transform
		material_override = StandardMaterial3D.new()
		material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material_override.disable_ambient_light = true
		var id_r = float(clone.id % 256)/256
		var id_g = float(floori(float(clone.id)/256))/256
		var id_b = float(floori(float(clone.id)/(256*256)))/256
		color = Color(id_r,id_g,id_b)
		material_override.albedo_color = color
	
	func _process(_delta: float) -> void:
		mesh = clone.mesh
		global_transform = clone.global_transform
	
	static func color_to_id(col : Color) -> int:
		return floori(col.r*256) + floori(col.g * 256 * 256) + floori(col.b * 256 * 256 * 256)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Return quietly if world is not yet set
	if world == null:
		push_warning("An IsoObjectNew was added to the tree without a set IsoWorld. It must be initialized manually.")
		return
	
	id = world.get_valid_id()
	world.index_object(self)
	
	clone = IdClone.new()
	clone.clone = self
	world.id_world.add_child(clone)
	id_color = clone.color

func _process(_delta: float) -> void:
	position = world.snap_position(position)
