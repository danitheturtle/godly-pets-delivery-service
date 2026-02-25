@tool
extends EditorPlugin

var dock

const SnapGizmo = preload("res://addons/snap_to_stair_grid_gizmo/snap_gizmo.gd")
var gizmo = SnapGizmo.new()

func _enable_plugin() -> void:
	add_autoload_singleton("StairGridState", "res://addons/snap_to_stair_grid_gizmo/stair_grid_state.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("StairGridState")

func _enter_tree() -> void:
	# create the settings dock
	dock = EditorDock.new()
	dock.title = "Stair Grid Snap Settings"
	dock.default_slot = EditorDock.DOCK_SLOT_RIGHT_BL
	var settingsDock = preload("res://addons/snap_to_stair_grid_gizmo/stair_grid_settings_dock.tscn").instantiate()
	dock.add_child(settingsDock)
	add_dock(dock)
	# put gizmos in tree
	add_node_3d_gizmo_plugin(gizmo)

func _exit_tree() -> void:
	# remove settings dock
	remove_dock(dock)
	dock.queue_free()
	dock = null
	# remove gizmos
	remove_node_3d_gizmo_plugin(gizmo)
