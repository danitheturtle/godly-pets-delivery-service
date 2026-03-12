extends Node
class_name StairGraphEdge

# represents one or more spaces for connected staircases between two platforms
# zero or more spaces can be empty and the graph edge will still exist
# the platform's job is to move actual stair game objects between its edges

var stairsRefs: Array[Stairs] = []
var platformA: Platform = null
var platformB: Platform = null

func _init(_edgeLength, _platformA, _platformB):
    for i in range(_edgeLength):
        stairsRefs.append(null)
