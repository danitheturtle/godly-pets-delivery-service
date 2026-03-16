extends Area3D
class_name Checkpoint

@export var isFirstInScene: bool = false
@export var isSubCheckpoint: bool = false

@onready var animationPlayer = $AnimationPlayer
@onready var parentLevel = Utils.get_parent_level(self)

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
    State.player.global_position = global_position
    State.player.velocity = Vector3(0,0,0)
    var petOffset = (State.player.global_basis.x + -State.player.global_basis.z) * 2.0
    State.pet.global_position = global_position + petOffset
    State.pet.velocity = Vector3(0,0,0)

func on_entered_activation_area(node: Node) -> void:
    if node is Player:
        playerInside = true
    elif node is Pet:
        petInside = true
    if (playerInside && petInside):
        activate_checkpoint()

func on_exited_activation_area(node: Node) -> void:
    if node is Player:
        playerInside = false
    elif node is Pet:
        petInside = false
