extends CharacterBody3D

@export var GRAVITY = -2
@export var PLAYER_SPEED = 1.5
@export var CAMERA_ANGULAR_VELOCITY = 0.1
var moveDir = Vector2(0.0,0.0)
var cameraMoveDir = Vector2(0.0,0.0)
var movePriority = { left = false, right = false, forward = false, backward = false }
var mouseCaptured = false

# child nodes
@onready var camera = $Camera3D
@onready var collider = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	if (cameraMoveDir.y < 0 && camera.rotation_degrees.x < 85) || (cameraMoveDir.y > 0 && camera.rotation_degrees.x > -85):
		camera.rotate_x(cameraMoveDir.y * -CAMERA_ANGULAR_VELOCITY)		
	rotate_y(cameraMoveDir.x * -CAMERA_ANGULAR_VELOCITY)
	#multiply basis vectors by input direction
	velocity = Vector3(basis.x * moveDir.x + basis.z * moveDir.y).limit_length() * PLAYER_SPEED
	#apply gravity
	velocity += Vector3(0.0, GRAVITY, 0.0)
	move_and_slide()
	pass;

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_mouse_input(event)
	elif event is InputEventJoypadMotion:
		handle_axis_input(event)
	else:
		handle_key_input(event)

func handle_mouse_input(event: InputEventMouseMotion) -> void:
	if mouseCaptured:
		cameraMoveDir = event.screen_relative / 100.0
		get_tree().root.set_input_as_handled()

func handle_key_input(event: InputEvent ) -> void:
	var eventHandled: bool = false
	# forward is pressed
	if (event.is_action_pressed("forward")):
		moveDir = Vector2(moveDir.x, -1)
		movePriority.backward = false
		movePriority.forward = !movePriority.left && !movePriority.right
		eventHandled = true
	# forward is released
	if (event.is_action_released("forward")):
		movePriority.forward = false
		if (Input.is_action_pressed("backward")):
			moveDir = Vector2(moveDir.x, 1)
			movePriority.backward = !movePriority.left && !movePriority.right
		else:
			moveDir = Vector2(moveDir.x, 0)
			movePriority.left = true if moveDir.x < 0 else false
			movePriority.right = true if moveDir.x > 0 else false
		eventHandled = true

	# backward is pressed
	if (event.is_action_pressed("backward")):
		moveDir = Vector2(moveDir.x, 1)
		movePriority.forward = false
		movePriority.backward = !movePriority.left && !movePriority.right
		eventHandled = true
	# backward is released
	if (event.is_action_released("backward")):
		if (Input.is_action_pressed("forward")):
			moveDir = Vector2(moveDir.x, -1)
			movePriority.forward = !movePriority.left && !movePriority.right
		else:
			moveDir = Vector2(moveDir.x, 0)
			movePriority.left = true if moveDir.x < 0 else false
			movePriority.right = true if moveDir.x > 0 else false
		movePriority.backward = false
		eventHandled = true

	# left is pressed
	if (event.is_action_pressed("left")):
		moveDir = Vector2(-1, moveDir.y)
		movePriority.right = false
		movePriority.left = !movePriority.forward && !movePriority.backward
		eventHandled = true
	# left is released
	if (event.is_action_released("left")):
		if (Input.is_action_pressed("right")):
			moveDir = Vector2(1, moveDir.y)
			movePriority.right = !movePriority.forward && !movePriority.backward
		else:
			moveDir = Vector2(0, moveDir.y)
			movePriority.backward = true if moveDir.y < 0 else false
			movePriority.forward = true if moveDir.y > 0 else false
		movePriority.left = false
		eventHandled = true

	# right is pressed
	if (event.is_action_pressed("right")):
		moveDir = Vector2(1, moveDir.y)
		movePriority.left = false
		movePriority.right = !movePriority.forward && !movePriority.backward
		eventHandled = true
	# right is released
	if (event.is_action_released("right")):
		if (Input.is_action_pressed("left")):
			moveDir = Vector2(-1, moveDir.y)
			movePriority.left = !movePriority.forward && !movePriority.backward
		else:
			moveDir = Vector2(0, moveDir.y)
			movePriority.backward = true if moveDir.y < 0 else false
			movePriority.forward = true if moveDir.y > 0 else false
		movePriority.right = false
		eventHandled = true
	
	moveDir = moveDir.normalized()
	
	if (event.is_action_pressed("capture_cursor") && !mouseCaptured):
		Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_CAPTURED)
		mouseCaptured = true
		eventHandled = true
	if (event.is_action_pressed("release_cursor") && mouseCaptured):
		Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_VISIBLE)
		mouseCaptured = false
		eventHandled = true
	if (event.is_action_pressed("toggle_cursor")):
		if (mouseCaptured):
			Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_VISIBLE)
			mouseCaptured = false
		else:
			Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_CAPTURED)
			mouseCaptured = true
	
	if (eventHandled):
		get_tree().root.set_input_as_handled()

func handle_axis_input(event: InputEventJoypadMotion) -> void:
	var eventHandled: bool = false
	#Vertical joystick movement
	if (event.is_action("forward") || event.is_action("backward")):
		moveDir = Vector2(moveDir.x, event.axis_value)
		eventHandled = true
	#Horizontal joystick movement
	if (event.is_action("left") || event.is_action("right")):
		moveDir = Vector2(event.axis_value, moveDir.y)
		eventHandled = true
	#camera
	if (event.is_action("camera_down") || event.is_action("camera_up")):
		cameraMoveDir = Vector2(cameraMoveDir.x, event.axis_value)
		eventHandled = true
	if (event.is_action("camera_left") || event.is_action("camera_right")):
		cameraMoveDir = Vector2(event.axis_value, cameraMoveDir.y)
		eventHandled = true
	#If vectors are tiny, set to zero
	if (moveDir.length_squared() < 0.01):
		moveDir = Vector2(0.0,0.0)
	if (cameraMoveDir.length_squared() < 0.01):
		cameraMoveDir = Vector2(0.0,0.0)
	if (eventHandled):
		get_tree().root.set_input_as_handled()
