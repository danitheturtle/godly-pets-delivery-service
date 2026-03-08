extends Node
class_name Level

@export var levelNumber: int = 1

@onready var levelCheckpoint = $Checkpoint

func restart_level():
    var resetableChildren = find_children("*")
    for child in resetableChildren:
        if child.is_in_group("resetable"):
            child.reset(true)
    State.touchedNodes = []
    if levelCheckpoint is Checkpoint:
        levelCheckpoint.activate_checkpoint()
        levelCheckpoint.reset_to_checkpoint()
