extends AnimatableBody3D
@export var secondsPerRotation = 1.0
@export var rotationStops = 4
@export var displayBasis: Basis = transform.basis

var basisStops: Array[Basis] = []
var rotationIndex: int = 0
var rotationTimer: float = 0.0

var rotationDir = 0
var cw_queued = false
var ccw_queued = false

func _ready() -> void:
	# calculate the bases this platform can stop at
	basisStops.append(Basis(transform.basis))
	var rotationPerStepRad = TAU / rotationStops
	for i in range(1, rotationStops):
		basisStops.append(basisStops[0].rotated(Vector3.UP, i*rotationPerStepRad).orthonormalized())

func _physics_process(delta: float) -> void:
	displayBasis = transform.basis
	
	if (rotationDir == 0):
		if (cw_queued):
			cw_queued = false
			rotationDir = -1
		if (ccw_queued):
			ccw_queued = false
			rotationDir = 1
	else:
		rotate_platform(rotationDir, delta)

func _unhandled_key_input(event: InputEvent) -> void:
	var eventHandled: bool = false
	# movement
	if (event.is_action_pressed("rotate_cw")):
		ccw_queued = false
		cw_queued = true
		eventHandled = true
	if (event.is_action_pressed("rotate_ccw")):
		cw_queued = false
		ccw_queued = true
		eventHandled = true
	# tell game event was handled and stop propagating
	if (eventHandled):
		get_tree().root.set_input_as_handled()

func rotate_platform(dir: int, delta: float) -> void:
	rotationTimer += delta
	var fromIndex: int = rotationIndex
	var toIndex: int = wrapi(rotationIndex + dir, 0, rotationStops)
	var normalizedPositionInRotation = Utils.easeInOutCubic(Utils.normf(rotationTimer, 0.0, secondsPerRotation))
	transform.basis = Basis(basisStops[fromIndex]).slerp(basisStops[toIndex], normalizedPositionInRotation).orthonormalized()
	# if rotation finished
	if (normalizedPositionInRotation >= 1.0):
		rotationIndex = toIndex
		rotationDir = 0
		rotationTimer = 0.0
