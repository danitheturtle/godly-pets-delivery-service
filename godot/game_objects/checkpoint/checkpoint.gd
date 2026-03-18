extends Area3D
class_name Checkpoint

@export var isFirstInScene: bool = false
@export var isSubCheckpoint: bool = false

@onready var animationPlayer = $AnimationPlayer
@onready var parentLevel = Utils.get_parent_level(self)

# Unlocked when player reaches it, activated when pet reaches it
var checkpointActivated = false

# local state
var playerInside = false
var petInside = false

func _ready() -> void:
    #SignalBus.player_interacted.connect(on_player_interacted)
    body_entered.connect(on_entered_activation_area)
    body_exited.connect(on_exited_activation_area)
    if isFirstInScene:
        activate_checkpoint()

func activate_checkpoint() -> void:
    State.set_level(parentLevel)
    if State.activeCheckpoint != null:
        if State.activeCheckpoint.animationPlayer is AnimationPlayer:
            State.activeCheckpoint.animationPlayer.stop()
    if State.pendingCheckpoint != self:
        State.pendingCheckpoint = self
        SignalBus.checkpoint_unlocked.emit()
    State.activeCheckpoint = self
    animationPlayer.play("checkpoint_active")
    SignalBus.checkpoint_activated.emit()
    checkpointActivated = true

func reset_to_checkpoint(actorNode: CharacterBody3D, offset: Vector3 = Vector3.ZERO) -> void:
    actorNode.global_position = global_position + offset
    actorNode.velocity = Vector3.ZERO

@warning_ignore("unused_parameter")
func reset(hard: bool = false) -> void:
    checkpointActivated = false

func on_entered_activation_area(node: Node) -> void:
    if node is Player:
        playerInside = true
        if !checkpointActivated || (State.pendingCheckpoint != State.activeCheckpoint && State.activeCheckpoint == self):
            State.pendingCheckpoint = self
            SignalBus.checkpoint_unlocked.emit()
    elif node is Pet:
        petInside = true
        if !checkpointActivated && State.pendingCheckpoint == self:
            activate_checkpoint()

func on_exited_activation_area(node: Node) -> void:
    if node is Player:
        playerInside = false
    elif node is Pet:
        petInside = false
