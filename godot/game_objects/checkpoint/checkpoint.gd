extends Area3D
class_name Checkpoint

@export var isFirstInScene: bool = false
@export var isSubCheckpoint: bool = false

@onready var animationPlayer = $AnimationPlayer
@onready var parentLevel = Utils.get_parent_level(self)

var canActivate = false

func _ready() -> void:
    SignalBus.player_interacted.connect(on_player_interacted)
    body_entered.connect(on_entered_activation_area)
    body_exited.connect(on_exited_activation_area)
    if isFirstInScene:
        activate_checkpoint()

func activate_checkpoint() -> void:
    State.set_level(parentLevel)
    if State.lastCheckpoint != null:
        if State.lastCheckpoint.animationPlayer is AnimationPlayer:
            State.lastCheckpoint.animationPlayer.stop()
    animationPlayer.play("checkpoint_active")
    State.lastCheckpoint = self
    State.touchedNodes = []
    SignalBus.checkpoint_activated.emit()

func reset_to_checkpoint() -> void:
    for resetable in State.touchedNodes:
        resetable.reset(false)
    State.player.global_transform.origin = global_transform.origin

func on_player_interacted() -> void:
    if (canActivate && State.lastCheckpoint != self):
        activate_checkpoint()

func on_entered_activation_area(node: Node) -> void:
    if node is Player:
        canActivate = true

func on_exited_activation_area(node: Node) -> void:
    if node is Player:
        canActivate = false
