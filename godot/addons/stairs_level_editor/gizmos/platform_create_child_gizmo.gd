@tool
extends EditorNode3DGizmoPlugin

const Constants = preload("res://addons/stairs_level_editor/constants.gd")
const Utils = preload("res://addons/stairs_level_editor/level_editor_utils.gd")

var pluginRef = null
var pluginState = {}
var editedNode: Platform = null

func _get_gizmo_name() -> String:
    return "PlatformCreateChildGizmo"

func _init() -> void:
    # todo make it look better
    create_handle_material("handles")

func setup(_pluginRef, _pluginState) -> void:
    pluginRef = _pluginRef
    pluginState = _pluginState

func _has_gizmo(node) -> bool:
    if (node is Platform):
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
    for i in range(editedNode.PIVOTS_STOPS):
        var rotationToPivot = Utils.get_rotation_to_pivot_matrix(i, editedNode.ROTATION_STOPS)
        handles.push_back(rotationToPivot * Vector3(0, 0.0, -pivotDist))
    gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary) -> String:
    editedNode = gizmo.get_node_3d() as Platform
    return "Pivot " + str(handleId)

func _commit_handle(gizmo, handleId, isSecondary, restore, cancel) -> void:
    editedNode = gizmo.get_node_3d() as Platform
    # TODO: add undo/redo
    #var _undoRedo = pluginRef.get_undo_redo()
    var newChildPuzzlePiece = Constants.puzzlePieceTypeToResourceMap[pluginState.puzzlePieceType].instantiate()
    var rotationMat = Utils.get_rotation_to_pivot_matrix(handleId, editedNode.ROTATION_STOPS)
    var newChildPuzzlePieceTransform = Transform3D(rotationMat, rotationMat * Vector3(0, 0, -editedNode.RADIUS))
    Utils.add_to_scene(editedNode.get_child(0), newChildPuzzlePiece, newChildPuzzlePieceTransform)

func is_gizmo_active() -> bool:
    return pluginState.placementMode == Constants.PLACEMENT_MODE.PUZZLE_PIECES && pluginState.puzzlePieceType == Constants.PUZZLE_PIECE_TYPE.STAIRS_SLOT_ATTACHED