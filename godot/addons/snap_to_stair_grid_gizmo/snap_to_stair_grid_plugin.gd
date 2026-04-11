@tool
extends EditorPlugin
class_name StairGridPlugin

var dock

const CreateAdjacentGizmoRes = preload("res://addons/snap_to_stair_grid_gizmo/create_adjacent_gizmo.gd")
var TesselatePlatforms = preload("res://addons/snap_to_stair_grid_gizmo/tesselate_platforms.gd").new()

var createAdjacentGizmo = CreateAdjacentGizmoRes.new()
var stairGridState = {
    placementMode = "platforms",
    platformType = CreateAdjacentGizmoRes.PLATFORM_TYPE.SQUARE,
    puzzlePieceType = CreateAdjacentGizmoRes.PUZZLE_PIECE_TYPE.STAIRS,
    platformSideCount = 4,
    platformSideLength = 9.75,
    stairSlopeRise = 11.25,
    stairSlopeRun = 19.5
}

#func _enable_plugin() -> void:
    #pass

#func _disable_plugin() -> void:
    #pass

func _enter_tree() -> void:
    # setup shortcuts
    var editorModeSwitchInputEventKey = InputEventKey.new()
    editorModeSwitchInputEventKey.keycode = KEY_ALT
    var editorModeSwitchShortcut = Shortcut.new()
    editorModeSwitchShortcut.events.append(editorModeSwitchInputEventKey)
    EditorInterface.get_editor_settings().add_shortcut("snap_to_stair_grid/editor_mode_switch", editorModeSwitchShortcut)
    # create the settings dock
    dock = EditorDock.new()
    dock.title = "Stair Grid Snap Settings"
    dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_BL
    var settingsDock = preload("res://addons/snap_to_stair_grid_gizmo/stair_grid_settings_dock.tscn").instantiate()
    settingsDock.setup(self, stairGridState)
    dock.add_child(settingsDock)
    add_dock(dock)
    # put gizmos in tree
    createAdjacentGizmo.setup(self, stairGridState)
    add_node_3d_gizmo_plugin(createAdjacentGizmo)

func _exit_tree() -> void:
    # remove settings dock
    remove_dock(dock)
    dock.queue_free()
    dock = null
    # remove gizmos
    remove_node_3d_gizmo_plugin(createAdjacentGizmo)

func on_mode_switch_toggled(toggledOn: bool) -> void:
    if (toggledOn):
        stairGridState.placementMode = "puzzlePieces"
    else:
        stairGridState.placementMode = "platforms"

func on_platform_resource_selected(selectedType: int) -> void:
    stairGridState.platformType = selectedType

func on_puzzle_piece_resource_selected(selectedType: int) -> void:
    stairGridState.puzzlePieceType = selectedType

func on_platform_side_length_changed(nextLength: float) -> void:
    stairGridState.platformSideLength = nextLength

func on_platform_side_count_changed(nextCount: int) -> void:
    stairGridState.platformSideCount = nextCount

func on_stair_slope_rise_changed(nextRise: float) -> void:
    stairGridState.stairSlopeRise = nextRise

func on_stair_slope_run_changed(nextRun: float) -> void:
    stairGridState.stairSlopeRun = nextRun
