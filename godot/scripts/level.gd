extends Node
class_name Level

@export var levelNumber: int = 1

@onready var levelCheckpoint = $Sub1/Checkpoint

func restart_level():
    var resetableChildren = Utils.get_children_in_group(self, "resetable", true)
    for child in resetableChildren:
        child.reset(true)
    State.touchedNodes = []
    if levelCheckpoint is Checkpoint:
        levelCheckpoint.reset_to_checkpoint()
