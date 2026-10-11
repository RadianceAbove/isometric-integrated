class_name IsoTile extends Resource
## A [Resource] that contains a texture and mesh for isometric rendering.
##
## An [IsoTile] is a type of [Resource] that contains data for rendering within
## an [IsoWorld]. Its [member mesh] is used for tracking depth and lighting, 
## while its [member texture] functions as an albedo texture, aligned to a pixel
## grid when rendered.

## The pixelized appearance of the [IsoTile].
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

## The alignment of the [IsoTile]'s [member texture] relative to its 
## [member mesh], if one is not centered on the origin.
@export var texture_offset : Vector2i

## The [Mesh] of the [IsoTile], used to track depth and lighting within the 
## [IsoWorld].
@export var mesh : Mesh

## The [Image] version of the [member texture], used to easily reference 
## specific pixels.
var image : Image
