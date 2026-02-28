extends Node

var player: Player = null
var loadedWorld: World = null
var lastCheckpoint: Checkpoint = null
var touchedNodes: Array[Node3D] = []

func reinit() -> void:
    player = null
    loadedWorld = null
    lastCheckpoint = null
    touchedNodes = []
