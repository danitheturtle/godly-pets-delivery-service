extends Node
class_name Level

@export var levelNumber: int = 1

@onready var levelCheckpoint = $Sub1/Checkpoint

func restart_level():
    reset_level()
    if levelCheckpoint is Checkpoint:
        State.touchedNodes = []
        levelCheckpoint.activate_checkpoint()
        SignalBus.checkpoint_activated.emit()
        SignalBus.reset_to_checkpoint.emit()

func reset_level() -> void:
    var resetableChildren = Utils.get_children_in_group(self, "resetable", true)
    for child in resetableChildren:
        child.reset(true)
