@tool
extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "SnapGizmo"

func _init():
	create_material("main", Color(1,0,0))
	create_handle_material("handles")

func _has_gizmo(node):
	if (node is Stairs || node is Platform):
		return true
	return false

func _redraw(gizmo):
	gizmo.clear()
	
	var node3d = gizmo.get_node_3d()

	var lines = PackedVector3Array()

	lines.push_back(Vector3(0, 0, 0))
	lines.push_back(Vector3(0, 1, 0))

	var handles = PackedVector3Array()

	handles.push_back(Vector3(0, 0, 0))
	handles.push_back(Vector3(0, 1, 0))

	gizmo.add_lines(lines, get_material("main", gizmo), false)
	gizmo.add_handles(handles, get_material("handles", gizmo), [])
