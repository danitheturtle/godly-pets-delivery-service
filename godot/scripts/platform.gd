extends AnimatableBody3D
@export var secondsPerRotation = 3.0
var startAngle = 0
var rotating = false
var cw_rotate_queued = false
var ccw_rotate_queued = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if (!rotating):
		rotating = true
		startAngle = rotation_degrees.y
	else:
		if (cw_rotate_queued):
			rotate_y(deg_to_rad((90.0 / secondsPerRotation) * delta))
		if (ccw_rotate_queued):
			rotate_y(deg_to_rad((-90.0 / secondsPerRotation) * delta))
		if (abs(rotation_degrees.y - startAngle) >= 90):
			rotating = false
			cw_rotate_queued = false
			ccw_rotate_queued = false

func _unhandled_key_input(event: InputEvent) -> void:
	var eventHandled: bool = false
	# movement
	if (event.is_action_pressed("rotate_cw")):
		ccw_rotate_queued = false
		cw_rotate_queued = true
		eventHandled = true
	if (event.is_action_pressed("rotate_ccw")):
		cw_rotate_queued = false
		ccw_rotate_queued = true
		eventHandled = true
	# tell game event was handled and stop propagating
	if (eventHandled):
		get_tree().root.set_input_as_handled()
