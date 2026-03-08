extends Node

# constant state
const worlds = {
    1: preload("res://worlds/world_1.tscn"),
    2: preload("res://worlds/world_2.tscn")
}
const levelCountByWorld = { 1: 2, 2: 1 }

# variable state
var player: Player = null
var world: World = null
var level: Level = null
var lastCheckpoint: Checkpoint = null
var touchedNodes: Array[Node3D] = []
var highestWorldReached: int = 1
var highestLevelReached: int = 1

func reinit() -> void:
    player = null
    world = null
    level = null
    lastCheckpoint = null
    touchedNodes = []
    highestWorldReached = 1
    highestLevelReached = 1

func set_world(_world: World) -> void:
    if (world != _world && _world != null):
        world = _world
        if highestWorldReached < world.worldNumber:
            highestWorldReached = world.worldNumber

func set_level(_level: Level) -> void:
    if (level != _level && _level != null):
        level = _level
        if highestLevelReached < level.levelNumber:
            highestLevelReached = level.levelNumber
