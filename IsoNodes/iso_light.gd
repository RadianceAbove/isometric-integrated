class_name IsoLight extends IsoNode

@export var color : Color = Color.WHITE
@export var distance : int = 64
@export var strength : float = 1

func get_data() -> Array:
	var global_pos = get_global_position()
	var out : Array = []
	
	out.append(position)
	out.append(Vector4(color.r,color.g,color.b,color.a))
	out.append(float(distance))
	out.append(strength)
	
	return out
