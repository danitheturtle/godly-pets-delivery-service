extends AnimatableBody3D
class_name Platform

# imports
const PlatformRotationClass = preload("res://game_objects/platform/platform_rotation.gd")
const collisionErrorMaterial: Material = preload("res://assets/materials/rotation_error.tres")

# editor-controlled values
@export var SECONDS_PER_ROTATION: float = 3.0
@export var SECONDS_PER_PIVOT: float = 3.0
@export var ROTATION_STOPS: int = 4
@export var PIVOTS_STOPS: int = 4

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
var rotationCancelled: bool = false

#pivot animation state
var pivots: Array[CollisionShape3D] = []
var pBasisStops: Array[Basis] = []
var pivotsCancelled: bool = false

#reset state
var initialTransform: Transform3D
var initialPivotsBases: Array[Basis]
var storedTransform: Transform3D
var storedPivotsBases: Array[Basis]

#local state
var rotationHandler: PlatformRotation = null
var playerOnPlatform: bool = false
var petOnPlatform: bool = false
var attachedStairRefs: Array[Stairs] = []

func _ready() -> void:
    rotationHandler = PlatformRotationClass.new(
        ROTATION_STOPS,
        PIVOTS_STOPS,
        SECONDS_PER_ROTATION,
        SECONDS_PER_PIVOT,
        self
    )
    # get nearest checkpoint
    for nextChild in get_parent().get_children():
        if nextChild is Checkpoint:
            closestCheckpoint = nextChild
            break
    # calculate the bases this platform can stop at
    basisStops.append(Basis(transform.basis))
    for i in range(1, ROTATION_STOPS):
        basisStops.append(basisStops[0].rotated(Vector3.UP, i*rotationHandler.rotationState.radPerStop).orthonormalized())
    # get array of stair pivot colliders
    for childPivot: Node in pivotsParent.get_children():
        if childPivot is Area3D:
            var collider: CollisionShape3D = childPivot.get_child(0)
            pivots.append(collider)
    # calculate the bases that pivots can stop at
    get_pivot_basis_stops(pivots[0])
    # setup reset state
    initialTransform = Transform3D(transform)
    storedTransform = initialTransform
    for nextPivot in pivots:
        initialPivotsBases.append(nextPivot.transform.basis)
    storedPivotsBases = Array(initialPivotsBases)
    # monitor actorDetector area for other bodies
    actorDetector.body_entered.connect(on_entered_control_area)
    actorDetector.body_exited.connect(on_exited_control_area)
    # listen for checkpoints
    SignalBus.checkpoint_unlocked.connect(on_checkpoint_reached)

func _physics_process(delta: float) -> void:
    rotationHandler.update(delta)
    # handle platform animation
    rotate_platform()
    # handle pivot animation
    rotate_pivots()

func _unhandled_key_input(event: InputEvent) -> void:
    if (!playerOnPlatform): return
    var eventHandled: bool = rotationHandler.on_unhandled_key_input(event)
    # tell game event was handled and stop propagating
    if (eventHandled):
        State.touchedNodes.append(self)
        get_tree().root.set_input_as_handled()

func reset(hard: bool = false) -> void:
    rotationHandler.reset(hard)
    # reinitialize animation variables
    rotationCancelled = false
    pivotsCancelled = false
    disconnect_attached_stair_signals()
    # hard or soft reset variables
    transform = initialTransform if hard else storedTransform
    for i in ROTATION_STOPS:
        pivots[i].transform.basis = initialPivotsBases[i] if hard else storedPivotsBases[i]

func rotate_platform() -> void:
    var rs = rotationHandler.rotationState
    transform.basis = Basis(basisStops[rs.currentIndex]).rotated(Vector3.UP, rs.currentRotationRad).orthonormalized()

func rotate_pivots() -> void:
    var ps = rotationHandler.pivotsState
    for i in range(ROTATION_STOPS):
        pivots[i].transform.basis = Basis(pBasisStops[ps.currentIndex]).rotated(Vector3.FORWARD, ps.currentRotationRad).orthonormalized()

func attach_adjacent_stairs() -> void:
    disconnect_attached_stair_signals()
    attachedStairRefs = []
    for nextPivot in pivots:
        var pivotCollisions = nextPivot.get_parent().get_overlapping_bodies()
        for col in pivotCollisions:
            if col is Stairs:
                col.attach_to_platform(self)
                attachedStairRefs.append(col)
                col.centerCollisionArea.body_entered.connect(on_body_entered_stair_center_area)
                col.endsCollisionArea.body_entered.connect(on_body_entered_stair_ends_area)
                if col.get_parent() != nextPivot:
                    State.touchedNodes.append(col)
                    col.reparent(nextPivot, true)

func disconnect_attached_stair_signals() -> void:
    for attachedStair in attachedStairRefs:
        if attachedStair.centerCollisionArea.is_connected("body_entered", on_body_entered_stair_center_area):
            attachedStair.centerCollisionArea.body_entered.disconnect(on_body_entered_stair_center_area)
        if attachedStair.endsCollisionArea.is_connected("body_entered", on_body_entered_stair_ends_area):
            attachedStair.endsCollisionArea.body_entered.disconnect(on_body_entered_stair_ends_area)

func get_pivot_basis_stops(pivot: CollisionShape3D) -> void:
    pBasisStops.append(Basis(pivot.transform.basis))
    for j in range(1,PIVOTS_STOPS):
        pBasisStops.append(pBasisStops[0].rotated(Vector3.FORWARD, -j*rotationHandler.pivotsState.radPerStop).orthonormalized())

func on_entered_control_area(node: Node) -> void:
    if node is Player:
        playerOnPlatform = true
    elif node is Pet:
        petOnPlatform = true

func on_exited_control_area(node: Node) -> void:
    if node is Player:
        playerOnPlatform = false
    elif node is Pet:
        petOnPlatform = false

func on_checkpoint_reached() -> void:
    storedTransform = Transform3D(transform)
    for i in range(pivots.size()):
        storedPivotsBases[i] = pivots[i].transform.basis
    rotationHandler.on_checkpoint_reached()

func on_rotation_started() -> void:
    platform_rotation_started.emit()
    attach_adjacent_stairs()

func on_pivot_started() -> void:
    stairs_pivot_started.emit()
    attach_adjacent_stairs()

func on_body_entered_stair_center_area(body: Node3D) -> void:
    handle_collision(2, body)

func on_body_entered_stair_ends_area(body: Node3D) -> void:
    handle_collision(3, body)

func handle_collision(collisionLayer: int, body: Node3D):
    if body == self || (body is PhysicsBody3D && (!body.get_collision_layer_value(collisionLayer))):
        return
    for nextAttachedStair in attachedStairRefs:
        if body == nextAttachedStair:
            return
    var collided = rotationHandler.on_collision()
    if collided:
        play_collision_animation(body)

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
