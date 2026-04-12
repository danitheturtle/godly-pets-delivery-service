@tool
extends EditorNode3DGizmoPlugin

const Constants = preload("res://addons/stairs_level_editor/constants.gd")
const Utils = preload("res://addons/stairs_level_editor/level_editor_utils.gd")

var pluginRef = null
var pluginState = {}
var editedNode: Platform = null

func _get_gizmo_name() -> String:
    return "PlatformCreateAdjacentGizmo"

func _init() -> void:
    # todo make it look better
    create_handle_material("handles")

func setup(_pluginRef, _pluginState) -> void:
    pluginRef = _pluginRef
    pluginState = _pluginState

func _has_gizmo(node) -> bool:
    if node is Platform:
        return true
    return false

func _redraw(gizmo) -> void:
    gizmo.clear()
    editedNode = gizmo.get_node_3d() as Platform
    if !is_gizmo_active(): return
    var handles = PackedVector3Array()
    # repeat for each pivot
    var pivotAngleRad: float = 0.0
    var pivotDist = editedNode.RADIUS
    # pivots incremented clockwise starting with negative Z (forward)
    for i in range(editedNode.PIVOTS_STOPS):
        var rotationToPivot = Utils.get_rotation_to_pivot_matrix(i, editedNode.ROTATION_STOPS)
        # moving clockwise, add handles 1.0 units away from center of pivot in all 4 directions
        handles.push_back(rotationToPivot * Vector3(0, 1.0, -pivotDist))
        handles.push_back(rotationToPivot * Vector3(1.0, 0, -pivotDist))
        handles.push_back(rotationToPivot * Vector3(0, -1.0, -pivotDist))
        handles.push_back(rotationToPivot * Vector3(-1.0, 0, -pivotDist))
    gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary) -> String:
    editedNode = gizmo.get_node_3d() as Platform
    return "Pivot " + str(floor(handleId / editedNode.ROTATION_STOPS)) + " Pos " + str(handleId % 4)

# handleId is order in which it was added
func _commit_handle(gizmo, handleId, isSecondary, restore, cancel) -> void:
    editedNode = gizmo.get_node_3d() as Platform
    
    # TODO: add undo/redo
    #var _undoRedo = pluginRef.get_undo_redo()

    var handleIndex = handleId % 4
    var pivotIndex = floor(handleId / editedNode.ROTATION_STOPS)
    var rotationToPivot = Utils.get_rotation_to_pivot_matrix(pivotIndex, editedNode.ROTATION_STOPS)
    if pluginState.placementMode == Constants.PLACEMENT_MODE.PLATFORMS:
        var newPlatform = Constants.platformTypeToResourceMap[pluginState.platformType].instantiate()
        var newPlatformTransform = get_next_platform_transform(handleIndex, editedNode.RADIUS + newPlatform.RADIUS)
        newPlatformTransform.origin = rotationToPivot * newPlatformTransform.origin + editedNode.transform.origin
        Utils.add_to_scene(editedNode, newPlatform, newPlatformTransform)
    elif pluginState.placementMode == Constants.PLACEMENT_MODE.PUZZLE_PIECES:
        var newPuzzlePiece = Constants.puzzlePieceTypeToResourceMap[pluginState.puzzlePieceType].instantiate()
        var newPuzzlePieceTransform = Transform3D.IDENTITY
        match pluginState.puzzlePieceType:
            Constants.PUZZLE_PIECE_TYPE.STAIRS:
                newPuzzlePieceTransform = get_next_stairs_transform(handleIndex, editedNode.RADIUS)
            Constants.PUZZLE_PIECE_TYPE.STAIRS_SLOT:
                newPuzzlePieceTransform = get_next_stairs_slot_transform(handleIndex, editedNode.RADIUS)
        newPuzzlePieceTransform.origin = rotationToPivot * newPuzzlePieceTransform.origin + editedNode.transform.origin
        newPuzzlePieceTransform.basis = rotationToPivot * newPuzzlePieceTransform.basis
        Utils.add_to_scene(editedNode, newPuzzlePiece, newPuzzlePieceTransform)

func get_next_platform_transform(handleIndex: int, platformRadiusTotal: float) -> Transform3D:
    var nextPlatformTransform = Transform3D(
        Basis.IDENTITY,
        Vector3(0, 0, -pluginState.stairsRun - platformRadiusTotal)
    )
    match handleIndex:
        0:
            nextPlatformTransform.origin.y = pluginState.stairsRise
        1:
            nextPlatformTransform.origin.x = pluginState.stairsRise
        2:
            nextPlatformTransform.origin.y = - pluginState.stairsRise
        3:
            nextPlatformTransform.origin.x = - pluginState.stairsRise
    return nextPlatformTransform

func get_next_stairs_transform(handleIndex: int, platformRadius: float) -> Transform3D:
    var nextStairTransform = Transform3D(
        Basis.IDENTITY,
        Vector3(0, 0, -pluginState.stairsRun / 2.0 - platformRadius)
    )
    match handleIndex:
        0:
            nextStairTransform.origin.y = pluginState.stairsRise / 2.0
        1:
            nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, PI / 2.0)
            nextStairTransform.origin.x = pluginState.stairsRise / 2.0
        2:
            nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, PI)
            nextStairTransform.origin.y = - pluginState.stairsRise / 2.0
        3:
            nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, -PI / 2.0)
            nextStairTransform.origin.x = - pluginState.stairsRise / 2.0
    return nextStairTransform

func get_next_stairs_slot_transform(handleIndex: int, platformRadius: float) -> Transform3D:
    var newTransform = get_next_platform_transform(handleIndex, platformRadius)
    newTransform.basis = Basis.IDENTITY.rotated(Vector3.UP, TAU / 2.0)
    return newTransform

func is_gizmo_active() -> bool:
    if pluginState.placementMode == Constants.PLACEMENT_MODE.PLATFORMS:
        return true
    elif (pluginState.puzzlePieceType == Constants.PUZZLE_PIECE_TYPE.STAIRS ||
          pluginState.puzzlePieceType == Constants.PUZZLE_PIECE_TYPE.STAIRS_SLOT):
        return true
    return false