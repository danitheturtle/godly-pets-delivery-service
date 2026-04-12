@tool
extends EditorNode3DGizmoPlugin

const Constants = preload("res://addons/stairs_level_editor/constants.gd")
const Utils = preload("res://addons/stairs_level_editor/level_editor_utils.gd")

var pluginRef = null
var pluginState = {}
var editedNode: Stairs = null

func _get_gizmo_name() -> String:
    return "StairsCreateAdjacentGizmo"

func _init() -> void:
    # todo make it look better with icon materials
    create_handle_material("handles")

func setup(_pluginRef, _pluginState) -> void:
    pluginRef = _pluginRef
    pluginState = _pluginState

func _has_gizmo(node) -> bool:
    if (node is Stairs):
        return true
    return false

func _redraw(gizmo) -> void:
    gizmo.clear()
    editedNode = gizmo.get_node_3d() as Stairs
    if !is_gizmo_active(): return
    var handles = PackedVector3Array()
    var topPos = Vector3(0,pluginState.stairsRise / 2.0, -pluginState.stairsRun / 2.0)
    var bottomPos = Vector3(0,-pluginState.stairsRise / 2.0, pluginState.stairsRun / 2.0)
    handles.push_back(topPos)
    handles.push_back(bottomPos)
    gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary) -> String:
    editedNode = gizmo.get_node_3d() as Stairs
    return "Top of Stairs" if handleId == 0 else "Bottom of Stairs"

# handleId is order in which it was added
func _commit_handle(gizmo, handleId, isSecondary, restore, cancel) -> void:
    editedNode = gizmo.get_node_3d() as Stairs
    # TODO: add undo/redo
    #var _undoRedo = pluginRef.get_undo_redo()
    if pluginState.placementMode == Constants.PLACEMENT_MODE.PLATFORMS:
        var newPlatform = Constants.platformTypeToResourceMap[pluginState.platformType].instantiate()
        var newPlatformTransform = get_next_platform_transform(handleId, newPlatform)
        newPlatformTransform.origin = editedNode.transform.basis * newPlatformTransform.origin + editedNode.transform.origin
        Utils.add_to_scene(editedNode, newPlatform, newPlatformTransform)
    elif pluginState.placementMode == Constants.PLACEMENT_MODE.PUZZLE_PIECES:
        var newPuzzlePiece = Constants.puzzlePieceTypeToResourceMap[pluginState.puzzlePieceType].instantiate()
        var newPuzzlePieceTransform = Transform3D.IDENTITY
        match pluginState.puzzlePieceType:
            Constants.PUZZLE_PIECE_TYPE.STAIRS:
                newPuzzlePieceTransform = get_next_stairs_transform(handleId)
                newPuzzlePieceTransform.basis = editedNode.transform.basis
            Constants.PUZZLE_PIECE_TYPE.STAIRS_SLOT:
                newPuzzlePieceTransform = get_next_stairs_slot_transform(handleId)
                newPuzzlePieceTransform.basis = newPuzzlePieceTransform.basis.rotated(Vector3.UP, editedNode.rotation.y)
        newPuzzlePieceTransform.origin = editedNode.transform.basis * newPuzzlePieceTransform.origin + editedNode.transform.origin
        Utils.add_to_scene(editedNode, newPuzzlePiece, newPuzzlePieceTransform)

func get_next_platform_transform(handleId: int, newPlatform: Platform) -> Transform3D:
    var nextPlatformTransform = Transform3D.IDENTITY
    if handleId == 0:
        nextPlatformTransform.origin.z -= (pluginState.stairsRun / 2.0) + newPlatform.RADIUS
        nextPlatformTransform.origin.y += pluginState.stairsRise / 2.0
    elif handleId == 1:
        nextPlatformTransform.origin.z += (pluginState.stairsRun / 2.0) + newPlatform.RADIUS
        nextPlatformTransform.origin.y -= pluginState.stairsRise / 2.0
    return nextPlatformTransform

func get_next_stairs_transform(handleId: int) -> Transform3D:
    var nextStairsTransform = Transform3D.IDENTITY
    if handleId == 0:
        nextStairsTransform.origin.z -= pluginState.stairsRun
        nextStairsTransform.origin.y += pluginState.stairsRise
    elif handleId == 1:
        nextStairsTransform.origin.z += pluginState.stairsRun
        nextStairsTransform.origin.y -= pluginState.stairsRise
    return nextStairsTransform

func get_next_stairs_slot_transform(handleId: int) -> Transform3D:
    var nextStairsTransform = Transform3D.IDENTITY
    if handleId == 0:
        nextStairsTransform.basis = Basis.IDENTITY.rotated(Vector3.UP, TAU / 2.0)
        nextStairsTransform.origin.z -= pluginState.stairsRun / 2.0
        nextStairsTransform.origin.y += pluginState.stairsRise / 2.0
    elif handleId == 1:
        nextStairsTransform.origin.z += pluginState.stairsRun / 2.0
        nextStairsTransform.origin.y -= pluginState.stairsRise / 2.0
    return nextStairsTransform

func is_gizmo_active() -> bool:
    if pluginState.placementMode == Constants.PLACEMENT_MODE.PLATFORMS:
        return true
    else:
        if (pluginState.puzzlePieceType == Constants.PUZZLE_PIECE_TYPE.STAIRS || 
            pluginState.puzzlePieceType == Constants.PUZZLE_PIECE_TYPE.STAIRS_SLOT):
            return true
    return false