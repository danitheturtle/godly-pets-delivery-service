extends AnimatableBody3D
class_name Platform

# imports
const PlatformRotationControllerClass = preload("res://game_objects/platform/platform_rotation_controller.gd")
const collisionErrorMaterial: Material = preload("res://assets/materials/rotation_error.material.tres")

# editor-controlled values
@export var SECONDS_PER_ROTATION: float = 1.0
@export var SECONDS_PER_PIVOT: float = 1.0
@export var MIN_TIME_PER_STOP: float = 0.35
@export var ROTATION_STOPS: int = 4
@export var PIVOTS_STOPS: int = 4

# node refs
@onready var pivotsParent: Node3D = $Pivots
@onready var actorDetector: Area3D = $ActorDetector
@onready var rotationProgressBar: RotationProgressViewport = $RotationProgressViewport
@onready var pivotProgressBar: RotationProgressViewport = $PivotsProgressViewport
@onready var parentLevel: Level = Utils.get_parent_level(self)
@onready var rotationProgressBarMesh: MeshInstance3D = $RotationProgressBar
@onready var pivotProgressBarMeshes = Utils.get_children_of_type($Pivots, MeshInstance3D, true)
# @onready var closestCheckpoint = Utils.get_child_of_type(get_parent(), Checkpoint)

#signals
signal platform_rotation_started
signal platform_rotation_cancelled
signal platform_rotation_finished

signal stairs_pivot_started
signal stairs_pivot_cancelled
signal stairs_pivot_finished

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
var rotationController: PlatformRotationController = null
var pivotsController: PlatformRotationController = null
var playerOnPlatform: bool = false
var petOnPlatform: bool = false
var attachedStairRefs: Array[Stairs] = []

func _ready() -> void:
    # setup rotation controllers
    rotationController = PlatformRotationControllerClass.new(ROTATION_STOPS,SECONDS_PER_ROTATION, MIN_TIME_PER_STOP, "rotate_clockwise", "rotate_counter_clockwise")
    pivotsController = PlatformRotationControllerClass.new(PIVOTS_STOPS,SECONDS_PER_PIVOT, MIN_TIME_PER_STOP, "rotate_pivots_clockwise", "rotate_pivots_counter_clockwise")
    # calculate the bases this platform can stop at
    basisStops.append(Basis(transform.basis))
    for i in range(1, ROTATION_STOPS):
        basisStops.append(basisStops[0].rotated(Vector3.UP, -i*rotationController.radPerStop).orthonormalized())
    # get array of stair pivot colliders
    for childPivot: Node in pivotsParent.get_children():
        if childPivot is Area3D:
            var collider: CollisionShape3D = childPivot.get_child(0)
            pivots.append(collider)
    # calculate the bases that pivots can stop at
    pBasisStops.append(Basis(pivots[0].transform.basis))
    for j in range(1,PIVOTS_STOPS):
        pBasisStops.append(pBasisStops[0].rotated(Vector3.FORWARD, j*pivotsController.radPerStop).orthonormalized())
    # setup reset state
    initialTransform = Transform3D(transform)
    storedTransform = initialTransform
    for nextPivot in pivots:
        initialPivotsBases.append(nextPivot.transform.basis)
    storedPivotsBases = Array(initialPivotsBases)
    # setup rotation progress UI
    rotationProgressBar.set_tracked_state(rotationController)
    pivotProgressBar.set_tracked_state(pivotsController)
    # monitor actorDetector area for other bodies
    actorDetector.body_entered.connect(on_entered_control_area)
    actorDetector.body_exited.connect(on_exited_control_area)
    # listen for checkpoints
    SignalBus.checkpoint_unlocked.connect(on_checkpoint_reached)

func _physics_process(delta: float) -> void:
    var rotationFinished = rotationController.update(delta)
    var pivotsFinished = pivotsController.update(delta)
    # update platform basis based on animation state
    if !rotationFinished:
        transform.basis = Basis(basisStops[rotationController.startIndex]).rotated(Vector3.UP, -rotationController.distFromStartRad).orthonormalized()
        #rotationProgressBarMesh.global_rotation.y = rotationController.currentPosRad
    else:
        on_rotation_finished()
    # update pivot bases based on animation state
    if !pivotsFinished:
        for i in range(PIVOTS_STOPS):
            pivots[i].transform.basis = Basis(pBasisStops[pivotsController.startIndex]).rotated(Vector3.FORWARD, pivotsController.distFromStartRad).orthonormalized()
    else:
        on_pivots_finished()

func _unhandled_key_input(event: InputEvent) -> void:
    if (!playerOnPlatform): return
    var rotationInputResult = rotationController.on_unhandled_key_input(event)
    if rotationInputResult == "rotation_started":
        on_rotation_started()
    var pivotsInputResult = pivotsController.on_unhandled_key_input(event)
    if pivotsInputResult == "rotation_started":
        on_pivots_started()
    var eventHandled = rotationInputResult == "handled" || rotationInputResult == "rotation_started" || pivotsInputResult == "handled" || pivotsInputResult == "rotation_started"
    # tell game event was handled and stop propagating
    if (eventHandled):
        State.touchedNodes.append(self)
        get_tree().root.set_input_as_handled()

func reset(hard: bool = false) -> void:
    rotationController.reset(hard)
    pivotsController.reset(hard)
    disconnect_attached_stair_signals()
    # hard or soft reset variables
    transform = initialTransform if hard else storedTransform
    for i in ROTATION_STOPS:
        pivots[i].transform.basis = initialPivotsBases[i] if hard else storedPivotsBases[i]

func attach_adjacent_stairs() -> void:
    disconnect_attached_stair_signals()
    attachedStairRefs = []
    for nextPivot in pivots:
        var pivotCollisions = nextPivot.get_parent().get_overlapping_bodies()
        var stairProgressBar = Utils.get_child_of_type(nextPivot.get_parent(), MeshInstance3D)
        for nextStair in pivotCollisions:
            if nextStair is Stairs:
                nextStair.attach_to_platform(self)
                attachedStairRefs.append(nextStair)
                nextStair.centerCollisionArea.body_entered.connect(on_body_entered_stair_center_area)
                nextStair.endsCollisionArea.body_entered.connect(on_body_entered_stair_ends_area)
                stairProgressBar.show()
                if nextStair.get_parent() != nextPivot:
                    State.touchedNodes.append(nextStair)
                    nextStair.reparent(nextPivot, true)
                    # stair can be attached at two points. If topCollider is closer, invert rotation
                    var distToBottomCollider = (global_position - nextStair.bottomCollider.global_position).length_squared()
                    var distToTopCollider = (global_position - nextStair.topCollider.global_position).length_squared()
                    stairProgressBar.global_rotation_degrees.z = nextStair.rotation_degrees.z + nextStair.rotation_degrees.y
                    if distToBottomCollider >= distToTopCollider:
                        stairProgressBar.global_rotation_degrees.z *= -1

func disconnect_attached_stair_signals() -> void:
    for nextProgressMesh in pivotProgressBarMeshes:
        nextProgressMesh.hide()
    for attachedStair in attachedStairRefs:
        if attachedStair.centerCollisionArea.is_connected("body_entered", on_body_entered_stair_center_area):
            attachedStair.centerCollisionArea.body_entered.disconnect(on_body_entered_stair_center_area)
        if attachedStair.endsCollisionArea.is_connected("body_entered", on_body_entered_stair_ends_area):
            attachedStair.endsCollisionArea.body_entered.disconnect(on_body_entered_stair_ends_area)

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
    rotationController.on_checkpoint_reached()
    pivotsController.on_checkpoint_reached()

func on_rotation_started() -> void:
    # rotate progress bar relative to player so they see it. Negate start position by adding it
    rotationProgressBarMesh.global_rotation.y = snappedf(State.player.global_rotation.y, rotationController.radPerStop) + rotationController.startPosRad
    rotationProgressBarMesh.show()
    platform_rotation_started.emit()
    attach_adjacent_stairs()

func on_rotation_finished() -> void:
    rotationProgressBarMesh.hide()
    platform_rotation_finished.emit(rotationController.cancelled)
    transform.basis = basisStops[rotationController.currentIndex]

func on_pivots_started() -> void:
    stairs_pivot_started.emit()
    attach_adjacent_stairs()

func on_pivots_finished() -> void:
    stairs_pivot_finished.emit(pivotsController.cancelled)
    for i in range(PIVOTS_STOPS):
        pivots[i].transform.basis = pBasisStops[pivotsController.currentIndex]

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
    var collision = false
    if rotationController.on_collision():
        collision = true
        platform_rotation_cancelled.emit()
    if pivotsController.on_collision():
        collision = true
        stairs_pivot_cancelled.emit()
    if collision:
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
