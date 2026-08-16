extends Control

@export var viewer : IsoViewer
@export var coord_label : Label
@export var color_swatch : ColorRect
@export var character : IsoObject


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var pix = viewer.get_pixel_at_position(get_local_mouse_position())
	if pix == null:
		coord_label.text = str(get_local_mouse_position()/viewer.size)
		color_swatch.color = Color.RED
	else:
		var pos = pix.position
		coord_label.text = str(pos)
		color_swatch.color = pix.color
		#color_swatch.color = viewer.texture.get_pixel(pos.x,pos.y)
	color_swatch.color = viewer.get_pixel_color_at_position(get_local_mouse_position())
	var col = color_swatch.color
	coord_label.text = str(col.r) + ", " + str(col.g) + ", " + str(col.b)
	
	if Input.is_action_just_pressed("move_up"):
		character.translate(Vector3i(0,2,0))
	elif Input.is_action_just_pressed("move_down"):
		character.translate(Vector3i(0,-2,0))
	elif Input.is_action_just_pressed("move_left"):
		character.translate(Vector3i(-1,0,0))
	elif Input.is_action_just_pressed("move_right"):
		character.translate(Vector3i(1,0,0))
	elif Input.is_action_just_pressed("move_vert_up"):
		character.translate(Vector3i(0,0,1))
	elif Input.is_action_just_pressed("move_vert_down"):
		character.translate(Vector3i(0,0,-1))
