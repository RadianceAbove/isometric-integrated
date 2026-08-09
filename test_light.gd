extends IsoLight

var theta = 0
var speed = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	theta = fmod(theta + delta * speed,2*PI)
	position = Vector3i(floor(cos(theta) * 30),floor(sin(theta)*30),30)
