@tool
extends EditorNode3DGizmoPlugin

const Constants = preload("res://addons/stairs_level_editor/constants.gd")

var pluginRef = null
var pluginState = {}

func _get_gizmo_name() -> String:
    return "StairsCreateAdjacentGizmo"

func _init() -> void:
    # todo make it look better
    create_material("main", Color(1,0,0))
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
    var editedNode = gizmo.get_node_3d()
    var handles = PackedVector3Array()
    var topPos = Vector3(0,pluginState.stairsRise / 2.0, -pluginState.stairsRun / 2.0)
    var bottomPos = Vector3(0,-pluginState.stairsRise / 2.0, pluginState.stairsRun / 2.0)
    handles.push_back(topPos)
    handles.push_back(bottomPos)
    gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary) -> String:
    return "Top of Stairs" if handleId == 0 else "Bottom of Stairs"

# handleId is order in which it was added
func _commit_handle(gizmo, handleId, isSecondary, restore, cancel) -> void:
    var sceneRoot = EditorInterface.get_edited_scene_root()
    var editedNode = gizmo.get_node_3d()
    pass
