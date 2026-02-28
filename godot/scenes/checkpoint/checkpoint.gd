extends Area3D
class_name Checkpoint

@export var isFirstInScene: bool = false
@onready var animationPlayer = $AnimationPlayer

var canActivate = false

func _ready() -> void:
	body_entered.connect(_entered_activation_area)
	body_exited.connect(_exited_activation_area)
	if isFirstInScene:
		activate_checkpoint()

func activate_checkpoint() -> void:
	if State.lastCheckpoint != null:
		if State.lastCheckpoint.animationPlayer is AnimationPlayer:
			State.lastCheckpoint.animationPlayer.stop()
	animationPlayer.play("checkpoint_active")
	State.lastCheckpoint = self
	State.touchedNodes = []
	SignalBus.checkpoint_activated.emit()

func _unhandled_input(event: InputEvent ) -> void:
	var eventHandled: bool = false
	if (event.is_action("reset")):
		if (State.lastCheckpoint == self):
			for resetable in State.touchedNodes:
				resetable.reset(false)
			State.player.global_transform.origin = global_transform.origin
			eventHandled = true
	if (event.is_action("interact") && canActivate && State.lastCheckpoint != self):
		activate_checkpoint()
	# tell game event was handled and stop propagating
	if (eventHandled):
		get_tree().root.set_input_as_handled()

func _entered_activation_area(node: Node) -> void:
	if node is Player:
		canActivate = true

func _exited_activation_area(node: Node) -> void:
	if node is Player:
		canActivate = false
