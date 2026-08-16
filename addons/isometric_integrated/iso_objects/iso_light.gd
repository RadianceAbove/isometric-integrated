class_name IsoLight extends IsoNode

@export var color : Color = Color.WHITE
@export var linear_falloff : float = 1
@export var quadratic_falloff : float = 1
@export var strength : float = 1

func get_data() -> Array:
	var global_pos = get_global_position()
	var out : Array = []
	
	out.append(position)
	out.append(Vector4(color.r,color.g,color.b,color.a))
	out.append(float(linear_falloff))
	out.append(float(quadratic_falloff))
	out.append(strength)
	
	return out
