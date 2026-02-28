extends AnimatableBody3D
class_name Platform

@export var secondsPerRotation: float = 1.0
@export var secondsPerStairRotation: float = 1.0
@export var rotationStops: int = 4

@onready var pivotsParent: Node3D = $Pivots
@onready var actorDetector: Area3D = $ActorDetector

#rotation animation state
var basisStops: Array[Basis] = []
var rotationDir: int = 0
var rotationIndex: int = 0
var rotationTimer: float = 0.0
var clockwiseQueued: bool = false
var counterClockwiseQueued: bool = false

#pivot animation state
var pivots: Array[CollisionShape3D] = []
var pivotsBasisStops: Array[Basis] = [] # 4 for each pivot
var pivotsRotationDir: int = 0
var pivotsRotationIndex: int = 0
var pivotsRotationTimer: float = 0.0
var pivotsClockwiseQueued: bool = false
var pivotsCounterClockwiseQueued: bool = false

#reset state
var initialTransform: Transform3D
var initialPivotsBases: Array[Basis]
var storedTransform: Transform3D
var storedPivotsBases: Array[Basis]
var storedRotationIndex: int
var storedPivotsRotationIndex: int

#local state
var platformControlled: bool = false

func _ready() -> void:
	# calculate the bases this platform can stop at
	basisStops.append(Basis(transform.basis))
	var rotationPerStepRad: float = TAU / rotationStops
	for i in range(1, rotationStops):
		basisStops.append(basisStops[0].rotated(Vector3.UP, i*rotationPerStepRad).orthonormalized())
	# get array of stair pivot areas and their basis stops
	for childPivot: Node in pivotsParent.get_children():
		if childPivot is Area3D:
			var collider: CollisionShape3D = childPivot.get_child(0)
			pivots.append(collider)
			get_pivot_basis_stops(collider)
	# setup reset state
	initialTransform = Transform3D(transform)
	storedTransform = initialTransform
	for nextPivot in pivots:
		initialPivotsBases.append(nextPivot.transform.basis)
	storedPivotsBases = Array(initialPivotsBases)
	storedRotationIndex = 0
	storedPivotsRotationIndex = 0
	# make sure the actor detector is monitoring for changes, and rig up its collision signal to a local function
	actorDetector.body_entered.connect(_entered_control_area)
	actorDetector.body_exited.connect(_exited_control_area)
	# listen for checkpoints
	SignalBus.checkpoint_activated.connect(_checkpoint_reached)

func _physics_process(delta: float) -> void:
	# handle platform animation
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
	# handle pivot animation
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
		State.touchedNodes.append(self)
		get_tree().root.set_input_as_handled()

func reset(hard: bool = false) -> void:
	# reinitialize animation variables
	rotationDir = 0
	rotationTimer = 0.0
	pivotsRotationDir = 0
	pivotsRotationTimer = 0.0
	clockwiseQueued = false
	counterClockwiseQueued = false
	pivotsClockwiseQueued = false
	pivotsCounterClockwiseQueued = false
	# hard or soft reset variables
	rotationIndex = 0 if hard else storedRotationIndex
	pivotsRotationIndex = 0 if hard else storedPivotsRotationIndex
	transform = initialTransform if hard else storedTransform
	for i in rotationStops:
		pivots[i].transform.basis = initialPivotsBases[i] if hard else storedPivotsBases[i]

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

func rotate_pivots(delta: float) -> void:
	pivotsRotationTimer += delta
	var fromIndex: int = pivotsRotationIndex
	var toIndex: int = wrapi(pivotsRotationIndex + pivotsRotationDir, 0, 4)
	var normalizedPositionInRotation = Utils.easeInOutCubic(Utils.normf(pivotsRotationTimer, 0.0, secondsPerStairRotation))
	for i in range(rotationStops):
		pivots[i].transform.basis = Basis(pivotsBasisStops[i*rotationStops + fromIndex]).slerp(pivotsBasisStops[i*rotationStops + toIndex], normalizedPositionInRotation).orthonormalized()
	if (normalizedPositionInRotation >= 1.0):
		pivotsRotationIndex = toIndex
		pivotsRotationDir = 0
		pivotsRotationTimer = 0.0

func attach_adjacent_stairs() -> void:
	for nextPivot in pivots:
		var pivotCollisions = nextPivot.get_parent().get_overlapping_bodies()
		for col in pivotCollisions:
			if (col is Stairs && col.get_parent() != nextPivot):
				State.touchedNodes.append(col)
				col.reparent(nextPivot, true)

func get_pivot_basis_stops(pivot: CollisionShape3D) -> void:
	var childPivotBasisIndex = pivotsBasisStops.size()
	pivotsBasisStops.append(Basis(pivot.transform.basis))
	for j in range(1,4):
		pivotsBasisStops.append(pivotsBasisStops[childPivotBasisIndex].rotated(Vector3.RIGHT, -j*(PI/2)).orthonormalized())

func _entered_control_area(node: Node) -> void:
	if (node is Player):
		platformControlled = true

func _exited_control_area(node: Node) -> void:
	if (node is Player):
		platformControlled = false

func _checkpoint_reached() -> void:
	storedTransform = Transform3D(transform)
	for i in range(pivots.size()):
		storedPivotsBases[i] = pivots[i].transform.basis
	storedRotationIndex = rotationIndex
	storedPivotsRotationIndex = pivotsRotationIndex
