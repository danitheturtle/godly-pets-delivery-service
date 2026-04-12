@tool
extends EditorPlugin
class_name StairsLevelEditorPlugin

var dock
const Constants = preload("res://addons/stairs_level_editor/constants.gd")
 
var allGizmos = [
    Constants.PlatformCreateAdjacentGizmoRes.new(),
    Constants.PlatformCreateChildGizmoRes.new(),
    Constants.StairsCreateAdjacentGizmoRes.new()
]
var pluginState = Constants.get_default_state()

func _enter_tree() -> void:
    # setup shortcuts
    var previouslySetupShortcut = EditorInterface.get_editor_settings().get_shortcut("stairs_level_editor/editor_mode_switch")
    if previouslySetupShortcut == null:
        var editorModeSwitchInputEventKey = InputEventKey.new()
        editorModeSwitchInputEventKey.keycode = KEY_ALT
        var editorModeSwitchShortcut = Shortcut.new()
        editorModeSwitchShortcut.events.append(editorModeSwitchInputEventKey)
        EditorInterface.get_editor_settings().add_shortcut("stairs_level_editor/editor_mode_switch", editorModeSwitchShortcut)
    # create the settings dock
    dock = EditorDock.new()
    dock.title = "Stairs Level Editor Settings"
    dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_BL
    var stairsLevelEditorDock = Constants.StairsLevelEditorDockRes.instantiate()
    stairsLevelEditorDock.setup(self, pluginState)
    dock.add_child(stairsLevelEditorDock)
    add_dock(dock)
    # put gizmos in tree
    for nextGizmo in allGizmos:
        nextGizmo.setup(self, pluginState)
        add_node_3d_gizmo_plugin(nextGizmo)

func _exit_tree() -> void:
    # remove settings dock
    remove_dock(dock)
    dock.queue_free()
    dock = null
    # remove gizmos
    for nextGizmo in allGizmos:
        remove_node_3d_gizmo_plugin(nextGizmo)

func on_mode_switch_toggled(toggledOn: bool) -> void:
    if (toggledOn):
        pluginState.placementMode = Constants.PLACEMENT_MODE.PUZZLE_PIECES
    else:
        pluginState.placementMode = Constants.PLACEMENT_MODE.PLATFORMS
    update_gizmos()

func on_platform_resource_selected(selectedType: int) -> void:
    pluginState.platformType = selectedType
    update_gizmos()

func on_puzzle_piece_resource_selected(selectedType: int) -> void:
    pluginState.puzzlePieceType = selectedType
    update_gizmos()

func on_stair_slope_rise_changed(nextRise: float) -> void:
    pluginState.stairsRise = nextRise
    update_gizmos()

func on_stair_slope_run_changed(nextRun: float) -> void:
    pluginState.stairsRun = nextRun
    update_gizmos()

func update_gizmos() -> void:
    for nextGizmo in allGizmos:
        if nextGizmo.editedNode != null:
            nextGizmo.editedNode.update_gizmos()