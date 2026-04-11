@tool
extends Node

const PlatformResource = preload("res://game_objects/platform/square_platform.tscn")

static func tesselate(pluginState):
    var placed: Dictionary[String, Platform] = {}
    var selectedNodes = EditorInterface.get_selection().get_top_selected_nodes()
    var selectedPlatform = null
    for nextNode in selectedNodes:
        if nextNode is Platform:
            selectedPlatform = nextNode
    if selectedPlatform == null:
        return
    placed.set(get_platform_key(selectedPlatform.transform.origin), selectedPlatform)
    var tesselationCount = 3
    var untesselatedCreatedPlatforms = place_adjacent_platforms(selectedPlatform, placed, selectedPlatform, pluginState)
    for t in range(0,tesselationCount):
        var thisLoopPlatforms = untesselatedCreatedPlatforms
        untesselatedCreatedPlatforms = []
        for nextPlatform in thisLoopPlatforms:
            untesselatedCreatedPlatforms.append_array(place_adjacent_platforms(nextPlatform, placed, selectedPlatform, pluginState))

static func get_platform_key(platformOrigin: Vector3):
    return str(snapped(platformOrigin.x, 0.25)) + "," + str(snapped(platformOrigin.z, 0.25))

# assumes platform is already in placed
static func place_adjacent_platforms(
    platform: Platform, 
    placed: Dictionary[String, Platform], 
    selectedPlatform: Platform, 
    state
) -> Array[Platform]:
    var newlyPlacedPlatforms: Array[Platform] = []
    var origin: Vector3 = platform.transform.origin
    var nextPlatformOrigins: PackedVector3Array = []
    var translateDist = state.platformSideLength + state.stairsRun
    var shiftDist = state.stairsRise
    for i in range(state.platformSideCount):
        var rotationMatrix = Basis.IDENTITY.rotated(Vector3.UP, -i * (TAU / state.platformSideCount))
        var newLocation1 = rotationMatrix * Vector3(-shiftDist, 0, -translateDist) + platform.transform.origin
        var newLocation1Key = get_platform_key(newLocation1)
        var newLocation2 = rotationMatrix * Vector3(shiftDist, 0, -translateDist) + platform.transform.origin
        var newLocation2Key = get_platform_key(newLocation2)
        if !placed.get(newLocation1Key):
            var newPlatform = add_platform_at_position(newLocation1, selectedPlatform)
            newlyPlacedPlatforms.append(newPlatform)
            placed.set(newLocation1Key, newPlatform)
        if !placed.get(newLocation2Key):
            var newPlatform = add_platform_at_position(newLocation2, selectedPlatform)
            newlyPlacedPlatforms.append(newPlatform)
            placed.set(newLocation2Key, newPlatform)
    return newlyPlacedPlatforms

static func add_platform_at_position(newOrigin: Vector3, selectedPlatform: Platform) -> Platform:
    var newPlatform = PlatformResource.instantiate()
    newPlatform.transform.origin = newOrigin
    selectedPlatform.get_parent().add_child(newPlatform)
    newPlatform.owner = EditorInterface.get_edited_scene_root()
    return newPlatform
