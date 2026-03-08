extends Node
class_name World

@export var worldNumber: int = 1

var levels: Dictionary[int, Level] = {}

func _ready() -> void:
    build_levels_dict()
    State.set_world(self)

func build_levels_dict() -> void:
    for nextChild in get_children():
        if nextChild is Level:
            levels.set(nextChild.levelNumber, nextChild)

func get_level(levelNumber: int = 1) -> Level:
    return levels[levelNumber]
