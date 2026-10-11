@tool
class_name IsoObject extends MeshInstance3D
## An object designed for isometric rendering within an [IsoWorld].
##
## An [IsoObject] is designed to render as a descendant of an [IsoWorld], using
## its mesh as a depth and lighting map for a 2d texture.[br]
## [b]Note:[/b] The mesh in this node is set using the [member tile] property,
## not the built-in [member mesh] property. Any mesh set there will be 
## overwritten. [br]
## [b]Note:[/b] The [member material_override] property is is used to align the 
## [IsoObject]'s mesh to the [IsoWorld], allowing smooth positioning of the 
## object while keeping pixel consistency in the isometric render. If the 
## [member material_override] is set, ensure this object's position is aligned
## to the [IsoWorld].

## The [IsoTile] containing the mesh and texture data for the [IsoObject].
@export var tile : IsoTile:
	set(value):
		mesh = value.mesh.duplicate()
		tile = value

## The world the [IsoObject] is contained in and will be rendered in.
var world : IsoWorld

## The id of the [IsoObject] for use in tracking its location in an [IsoWorld] render.
var id : int = 0

## The clone of the [IsoObject], used by [IsoWorld] to track its screenspace location.
var clone : IsoObjectClone


## A node shadowing the movements of an [IsoObject].
##
## An [IsoObjectClone] is linked to an [IsoObject] via its 
## [member IsoObjectClone.clone] property, and will copy the global position of
## that object. It is used by an [IsoWorld] to track the depth of the object at
## any given pixel.
class IsoObjectClone extends MeshInstance3D:
	## The [IsoObject] to copy.
	var clone : IsoObject
	## The color to index by in the [IsoWorld] while tracking object depth.
	var color : Color
	
	
	## Convert a color to the id of an [IsoObject].
	static func color_to_id(col : Color) -> int:
		return floori(col.r*256) + floori(col.g * 256 * 256) + floori(col.b * 256 * 256 * 256)
	
	
	# Convert an id to a nuique color
	func _id_to_color(id : int) -> Color:
		var id_r = float(id % 256)/256
		var id_g = float(floori(float(id)/256))/256
		var id_b = float(floori(float(id)/(256*256)))/256
		return Color(id_r,id_g,id_b)
	
	
	func _ready() -> void:
		mesh = clone.mesh
		global_transform = clone.global_transform
		material_override = StandardMaterial3D.new()
		material_override.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material_override.disable_ambient_light = true
		color = _id_to_color(clone.id)
		material_override.albedo_color = color
		position = clone.world.snap_position(clone.position)
	
	
	func _process(_delta: float) -> void:
		mesh = clone.mesh
		global_transform = clone.global_transform
		global_position = clone.world.snap_position(clone.global_position)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		# Return quietly if world is not yet set
		world = IsoWorld.get_world(self)
		if world == null:
			push_warning("An IsoObject was added to the tree without a parent IsoWorld. It must be initialized manually.")
			return
		
		id = world.get_valid_id()
		world.index_object(self)
		
		clone = IsoObjectClone.new()
		clone.clone = self
		world.add_clone(clone)
		
		# Load alignment material
		var mat : ShaderMaterial = load("res://addons/isometric_integrated/core_objects/iso_mesh_aligner.tres")
		set_surface_override_material(0,mat)
		mat.set_shader_parameter("pixel_size",world.pixel_widths)
