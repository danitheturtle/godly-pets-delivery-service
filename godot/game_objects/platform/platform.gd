extends AnimatableBody3D
class_name Platform

# imports
const collisionErrorMaterial: Material = preload("res://assets/materials/rotation_error.material")

# editor-controlled values
@export var secondsPerRotation: float = 1.0
@export var secondsPerStairRotation: float = 1.0
@export var rotationStops: int = 4

# node refs
@onready var pivotsParent: Node3D = $Pivots
@onready var actorDetector: Area3D = $ActorDetector
@onready var parentLevel = Utils.get_parent_level(self)

#signals
signal platform_rotation_started
signal platform_rotation_cancelled
signal platform_rotation_finished

signal stairs_pivot_started
signal stairs_pivot_cancelled
signal stairs_pivot_finished

# StiarGrid info representing place in the level
var closestCheckpoint: Checkpoint

#rotation animation state
var basisStops: Array[Basis] = []
var rotationDir: int = 0
var rotationIndex: int = 0
var rotationTimer: float = 0.0
var rotationCancelled: bool = false
var clockwiseQueued: bool = false
var counterClockwiseQueued: bool = false

#pivot animation state
var pivots: Array[CollisionShape3D] = []
var pivotsBasisStops: Array[Basis] = [] # 4 for each pivot
var pivotsRotationDir: int = 0
var pivotsRotationIndex: int = 0
var pivotsRotationTimer: float = 0.0
var pivotsRotationCancelled: bool = false
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
var attachedStairRefs: Array[Stairs] = []

func _ready() -> void:
    # get nearest checkpoint
    for nextChild in get_parent().get_children():
        if nextChild is Checkpoint:
            closestCheckpoint = nextChild
            break
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
    actorDetector.body_entered.connect(on_entered_control_area)
    actorDetector.body_exited.connect(on_exited_control_area)
    # listen for checkpoints
    SignalBus.checkpoint_activated.connect(on_checkpoint_reached)

func _physics_process(delta: float) -> void:
    # handle platform animation
    if (rotationDir == 0):
        if clockwiseQueued || counterClockwiseQueued:
            platform_rotation_started.emit()
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
        if pivotsClockwiseQueued || pivotsCounterClockwiseQueued:
            stairs_pivot_started.emit()
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
    rotationCancelled = false
    pivotsRotationDir = 0
    pivotsRotationTimer = 0.0
    pivotsRotationCancelled = false
    clockwiseQueued = false
    counterClockwiseQueued = false
    pivotsClockwiseQueued = false
    pivotsCounterClockwiseQueued = false
    disconnect_attached_stair_signals()
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
        platform_rotation_finished.emit(rotationCancelled)
        rotationCancelled = false
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
        stairs_pivot_finished.emit(pivotsRotationCancelled)
        pivotsRotationCancelled = false
        pivotsRotationIndex = toIndex
        pivotsRotationDir = 0
        pivotsRotationTimer = 0.0

func attach_adjacent_stairs() -> void:
    disconnect_attached_stair_signals()
    attachedStairRefs = []
    for nextPivot in pivots:
        var pivotCollisions = nextPivot.get_parent().get_overlapping_bodies()
        for col in pivotCollisions:
            if col is Stairs:
                col.attach_to_platform(self)
                attachedStairRefs.append(col)
                col.collisionArea.body_entered.connect(on_body_entered_stair_area)
                col.secondaryCollisionArea.body_entered.connect(on_body_entered_stair_secondary_area)
                if col.get_parent() != nextPivot:
                    State.touchedNodes.append(col)
                    col.reparent(nextPivot, true)

func disconnect_attached_stair_signals() -> void:
    for attachedStair in attachedStairRefs:
        if attachedStair.collisionArea.is_connected("body_entered", on_body_entered_stair_area):
            attachedStair.collisionArea.body_entered.disconnect(on_body_entered_stair_area)
        if attachedStair.secondaryCollisionArea.is_connected("body_entered", on_body_entered_stair_secondary_area):
            attachedStair.secondaryCollisionArea.body_entered.disconnect(on_body_entered_stair_secondary_area)

func get_pivot_basis_stops(pivot: CollisionShape3D) -> void:
    var childPivotBasisIndex = pivotsBasisStops.size()
    pivotsBasisStops.append(Basis(pivot.transform.basis))
    for j in range(1,4):
        pivotsBasisStops.append(pivotsBasisStops[childPivotBasisIndex].rotated(Vector3.RIGHT, -j*(PI/2)).orthonormalized())

func on_entered_control_area(node: Node) -> void:
    if (node is Player):
        platformControlled = true
        if (closestCheckpoint != State.lastCheckpoint):
            closestCheckpoint.activate_checkpoint()

func on_exited_control_area(node: Node) -> void:
    if (node is Player):
        platformControlled = false

func on_checkpoint_reached() -> void:
    storedTransform = Transform3D(transform)
    for i in range(pivots.size()):
        storedPivotsBases[i] = pivots[i].transform.basis
    storedRotationIndex = rotationIndex
    storedPivotsRotationIndex = pivotsRotationIndex

func on_body_entered_stair_area(body: Node3D) -> void:
    handle_collision(2, body)

func on_body_entered_stair_secondary_area(body: Node3D) -> void:
    handle_collision(3, body)

func handle_collision(collisionLayer: int, body: Node3D):
    if body == self || (body is PhysicsBody3D && (!body.get_collision_layer_value(collisionLayer))):
        return
    for nextAttachedStair in attachedStairRefs:
        if body == nextAttachedStair:
            return
    # play animation and error sound on entering body
    if rotationDir != 0 && !rotationCancelled:
        rotationCancelled = true
        rotationIndex = wrapi(rotationIndex + rotationDir, 0, rotationStops)
        rotationDir *= -1
        rotationTimer = secondsPerRotation - rotationTimer
        play_collision_animation(body)
        platform_rotation_cancelled.emit()
    if pivotsRotationDir != 0 && !pivotsRotationCancelled:
        pivotsRotationCancelled = true
        pivotsRotationIndex = wrapi(pivotsRotationIndex + pivotsRotationDir, 0, 4)
        pivotsRotationDir *= -1
        pivotsRotationTimer = secondsPerRotation - pivotsRotationTimer
        play_collision_animation(body)
        stairs_pivot_cancelled.emit()

func play_collision_animation(body: PhysicsBody3D) -> void:
    # get physics object's mesh
    var meshInstance = []
    for nextChild in body.get_children():
        if nextChild is MeshInstance3D:
            meshInstance.append(nextChild)
    for nextMesh in meshInstance:
        nextMesh.material_overlay = collisionErrorMaterial
    await get_tree().create_timer(1.0).timeout
    for nextMesh in meshInstance:
        nextMesh.material_overlay = null
