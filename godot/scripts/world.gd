extends Node
class_name World

@export var worldNumber: int = 1

var levels: Dictionary[int, Level] = {}

func _ready() -> void:
    build_levels_dict()
    State.set_world(self)
    for toRemove in get_tree().get_nodes_in_group("remove_at_runtime"):
        toRemove.get_parent().remove_child(toRemove)

func build_levels_dict() -> void:
    var levelsInWorld = Utils.get_children_of_type(self, Level)
    for nextLevel in levelsInWorld:
        levels.set(nextLevel.levelNumber, nextLevel)

func get_level(levelNumber: int = 1) -> Level:
    return levels[levelNumber]
