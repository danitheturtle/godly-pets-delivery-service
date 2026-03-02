extends Node

var player: Player = null
var world: World = null
var level: Level = null
var lastCheckpoint: Checkpoint = null
var touchedNodes: Array[Node3D] = []

func reinit() -> void:
    player = null
    world = null
    level = null
    lastCheckpoint = null
    touchedNodes = []
