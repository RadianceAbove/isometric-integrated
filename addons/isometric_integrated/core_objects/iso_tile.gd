class_name IsoTile extends Resource

@export var texture : CompressedTexture2D :
	set(value):
		var s := value.get_size()
		if floori(s.x) % 2 != 0:
			push_warning("The width of an IsoTile Texture must be even.")
			return
		if floori(s.y) % 2 != 0:
			push_warning("The height of an IsoTile Texture must be even.")
			return
		image = value.get_image()
		texture = value

@export var texture_offset : Vector2i

@export var mesh : Mesh

var image : Image
