# Graph node for the StairGraph graph data structure
class_name StairGraphNode

var platformRef: Platform
# nodes
var adjacentPlatforms: Dictionary[int,Platform] = {}
# edges
var adjacentStairs: Dictionary[int,Stairs] = {}

# effectively the dicts are this without the null padding:
#var adjacentPlatforms: Array[Platform] = [
    #null,null,null,null,
    #null,null,null,null,
    #null,null,null,null,
    #null,null,null,null
#]
#var adjacentStairs: Array[Stairs] = [
    #null,null,null,null,
    #null,null,null,null,
    #null,null,null,null,
    #null,null,null,null
#]

func _init(_platformRef: Platform):
    platformRef = _platformRef

func set_platform(rotationIndex: int, stairPositionIndex: int, platform: Platform):
    adjacentPlatforms.set(rotationIndex + stairPositionIndex, platform)

func get_platform(rotationIndex: int, stairPositionIndex: int):
    return adjacentPlatforms.get(rotationIndex + stairPositionIndex)

func set_stairs(rotationIndex: int, stairPositionIndex: int, stairs: Stairs):
    adjacentStairs.set(rotationIndex + stairPositionIndex, stairs)

func get_stairs(rotationIndex: int, stairPositionIndex: int):
    return adjacentStairs.get(rotationIndex + stairPositionIndex)

func build_refs(worldSpaceState: PhysicsDirectSpaceState3D):
    # store initial pivot locations
    # stairs can be more than 1 long. raycast to find platforms
    # var query = PhysicsRayQueryParameters3D.create()
    pass

# rotates and updates refs for connected nodes
func rotate(dir: int):
    # TODO: update stair refs in adjacent nodes.
    # TODO: platform refs don't change until moving platforms happen
    var oldPlatformLocations = []
    var oldStairLocations = []
    # build null-padded arrays from graph node
    for i in range(platformRef.rotationStops):
        for s in range(4):
            oldPlatformLocations.append(get_platform(i,s))
            oldStairLocations.append(get_stairs(i,s))
    # rotate based on direction
    for i in range(platformRef.rotationStops):
        var potentialPlatformRefs = [oldPlatformLocations[i],oldPlatformLocations[i+1],oldPlatformLocations[i+2],oldPlatformLocations[i+3]]
        var potentialStairsRefs = [oldStairLocations[i],oldStairLocations[i+1],oldStairLocations[i+2],oldStairLocations[i+3]]
        for s in range(4):
            var wrappedIndex = wrapi(i + dir, 0, platformRef.rotationStops-1)
            if potentialPlatformRefs[s] != null:
                set_platform(wrappedIndex, s, potentialPlatformRefs[s])
            else:
                adjacentPlatforms.erase(wrappedIndex + s)
            if potentialStairsRefs[s] != null:
                set_stairs(wrappedIndex, s, potentialStairsRefs[s])
            else:
                adjacentStairs.erase(wrappedIndex + s)
        
    pass
# rotates stairs and updates refs for connected nodes
func rotate_stairs(dir: int):
    # TODO: update stair refs in adjacent nodes
    for i in range(platformRef.rotationStops):
        var potentialStairRefs = [get_stairs(i,0),get_stairs(i,1),get_stairs(i,2),get_stairs(i,3)]
        for s in range(potentialStairRefs.size()):
            if potentialStairRefs[s] != null:
                set_stairs(i, wrapi(s + dir, 0, 3), potentialStairRefs[s])
            else:
                adjacentStairs.erase(i + wrapi(s + dir, 0, 3))
