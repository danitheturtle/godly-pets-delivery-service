@tool
extends EditorPlugin
class_name StairGridPlugin

var dock

const CreateAdjacentGizmoRes = preload("res://addons/snap_to_stair_grid_gizmo/create_adjacent_gizmo.gd")
var createAdjacentGizmo = CreateAdjacentGizmoRes.new()
var stairGridState = {
	placementMode = "platforms",
	gridOrigin = Vector3(0,0,0),
	platformSideCount = 4,
	platformSideLength = 9.0,
	stairSlopeRise = 11.25,
	stairSlopeRun = 19.5
}

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
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

func _mode_switch_toggled(toggledOn: bool):
	if (toggledOn):
		stairGridState.placementMode = "stairs"
	else:
		stairGridState.placementMode = "platforms"

func _grid_origin_x_changed(nextX: float):
	stairGridState.gridOrigin.x = nextX
	
func _grid_origin_y_changed(nextY: float):
	stairGridState.gridOrigin.y = nextY

func _grid_origin_z_changed(nextZ: float):
	stairGridState.gridOrigin.z = nextZ

func _platform_side_length_changed(nextLength: float):
	stairGridState.platformSideLength = nextLength

func _platform_side_count_changed(nextCount: int):
	stairGridState.platformSideCount = nextCount

func _stair_slope_rise_changed(nextRise: float):
	stairGridState.stairSlopeRise = nextRise

func _stair_slope_run_changed(nextRun: float):
	stairGridState.stairSlopeRun = nextRun
