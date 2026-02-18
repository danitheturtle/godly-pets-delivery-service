extends Area3D
class_name Checkpoint

@export var isFirstInLevel: bool = false

func activate_checkpoint() -> void:
	State.lastCheckpoint = self

func _unhandled_input(event: InputEvent ) -> void:
	var eventHandled: bool = false
	if (event.is_action("reset")):
		if (isFirstInLevel || State.lastCheckpoint == self):
			for resetable in State.touchedNodes:
				resetable.reset()
			State.player.transform.origin = transform.origin
			eventHandled = true
	# tell game event was handled and stop propagating
	if (eventHandled):
		get_tree().root.set_input_as_handled()
