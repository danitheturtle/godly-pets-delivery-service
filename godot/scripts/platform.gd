extends AnimatableBody3D
class_name Platform

@export var secondsPerRotation = 1.0
@export var secondsPerStairRotation = 1.0
@export var rotationStops = 4
@export var displayBasis: Basis = transform.basis

@onready var pivotsParent = $Pivots
@onready var actorDetector = $ActorDetector

var basisStops: Array[Basis] = []
var rotationDir = 0
var rotationIndex: int = 0
var rotationTimer: float = 0.0

var pivots: Array[Area3D] = []
var pivotsBasisStops: Array[Basis] = [] # 4 for each pivot
var pivotsRotationDir: int = 0
var pivotsRotationIndex: int = 0
var pivotsRotationTimer: float = 0.0

var platformControlled = false

var clockwiseQueued = false
var counterClockwiseQueued = false
var pivotsClockwiseQueued = false
var pivotsCounterClockwiseQueued = false

func _ready() -> void:
	# calculate the bases this platform can stop at
	basisStops.append(Basis(transform.basis))
	var rotationPerStepRad = TAU / rotationStops
	for i in range(1, rotationStops):
		basisStops.append(basisStops[0].rotated(Vector3.UP, i*rotationPerStepRad).orthonormalized())
	
	# make sure the actor detector is monitoring for changes, and rig up its collision signal to a local function
	actorDetector.body_entered.connect(_entered_control_area)
	actorDetector.body_exited.connect(_exited_control_area)
	
	# get array of stair pivot areas and their basis stops
	for childPivot: Node in pivotsParent.get_children():
		if childPivot is Area3D:
			pivots.append(childPivot)
			get_pivot_basis_stops(childPivot)
	pass

func _physics_process(delta: float) -> void:
	displayBasis = pivots[0].transform.basis
	if (rotationDir == 0):
		if (clockwiseQueued):
			clockwiseQueued = false
			rotationDir += -1
			attach_adjacent_stairs()
		if (counterClockwiseQueued):
			counterClockwiseQueued = false
			rotationDir += 1
			attach_adjacent_stairs()
	else:
		rotate_platform(delta)
	if (pivotsRotationDir == 0):
		if (pivotsClockwiseQueued):
			pivotsClockwiseQueued = false
			pivotsRotationDir += -1
			attach_adjacent_stairs()
		if (pivotsCounterClockwiseQueued):
			pivotsCounterClockwiseQueued = false
			pivotsRotationDir += 1
			attach_adjacent_stairs()
	else:
		rotate_pivots(delta)
	pass

func _unhandled_key_input(event: InputEvent) -> void:
	if (!platformControlled): return
	var eventHandled: bool = false
	# movement
	if (event.is_action_pressed("rotate_clockwise", false, true)):
		counterClockwiseQueued = false
		clockwiseQueued = true
		eventHandled = true
	if (event.is_action_pressed("rotate_counter_clockwise", false, true)):
		clockwiseQueued = false
		counterClockwiseQueued = true
		eventHandled = true
	if (event.is_action_pressed("rotate_pivots_clockwise", false, true)):
		pivotsCounterClockwiseQueued = false
		pivotsClockwiseQueued = true
		eventHandled = true
	if (event.is_action_pressed("rotate_pivots_counter_clockwise", false, true)):
		pivotsClockwiseQueued = false
		pivotsCounterClockwiseQueued = true
		eventHandled = true
	# tell game event was handled and stop propagating
	if (eventHandled):
		get_tree().root.set_input_as_handled()
	pass

func rotate_platform(delta: float) -> void:
	rotationTimer += delta
	var fromIndex: int = rotationIndex
	var toIndex: int = wrapi(rotationIndex + rotationDir, 0, rotationStops)
	var normalizedPositionInRotation = Utils.easeInOutCubic(Utils.normf(rotationTimer, 0.0, secondsPerRotation))
	transform.basis = Basis(basisStops[fromIndex]).slerp(basisStops[toIndex], normalizedPositionInRotation).orthonormalized()
	# if rotation finished
	if (normalizedPositionInRotation >= 1.0):
		rotationIndex = toIndex
		rotationDir = 0
		rotationTimer = 0.0
	pass

func rotate_pivots(delta: float) -> void:
	pivotsRotationTimer += delta
	var fromIndex: int = pivotsRotationIndex
	var toIndex: int = wrapi(pivotsRotationIndex + pivotsRotationDir, 0, 4)
	var normalizedPositionInRotation = Utils.easeInOutCubic(Utils.normf(pivotsRotationTimer, 0.0, secondsPerStairRotation))
	for i in range(3):
		pivots[i].transform.basis = Basis(pivotsBasisStops[i*4 + fromIndex]).slerp(pivotsBasisStops[i*4 + toIndex], normalizedPositionInRotation).orthonormalized()
	if (normalizedPositionInRotation >= 1.0):
		pivotsRotationIndex = toIndex
		pivotsRotationDir = 0
		pivotsRotationTimer = 0.0
	pass

func attach_adjacent_stairs() -> void:
	for nextPivot in pivots:
		var pivotCollisions = nextPivot.get_overlapping_bodies()
		for col in pivotCollisions:
			if (col is Stairs && col.get_parent() != nextPivot):
				col.reparent(nextPivot, true)
	pass

func get_pivot_basis_stops(pivot: Area3D):
	var childPivotBasisIndex = pivotsBasisStops.size()
	pivotsBasisStops.append(Basis(pivot.transform.basis))
	for j in range(1,4):
		pivotsBasisStops.append(pivotsBasisStops[childPivotBasisIndex].rotated(Vector3.RIGHT, j*(PI/2)).orthonormalized())
	pass

func _entered_control_area(node: Node):
	if (node is Player):
		platformControlled = true
	pass

func _exited_control_area(node: Node):
	if (node is Player):
		platformControlled = false
	pass
