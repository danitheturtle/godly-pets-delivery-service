@tool
extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "SnapGizmo"

func _init():
	create_material("main", Color(1,0,0))
	create_handle_material("handles")

func _has_gizmo(node):
	if (node is Platform):
		return true
	return false

func _redraw(gizmo):
	gizmo.clear()
	var editedNode = gizmo.get_node_3d()
	if editedNode is Platform:
		pass
	var handles = PackedVector3Array()
	
	# repeat for each pivot
	var pivotAngleRad: float = 0.0
	var pivotDist = StairGridState.platformSideLength / 2
	for i in range(StairGridState.platformSideCount):
		pivotAngleRad += i * (TAU / StairGridState.platformSideCount)
		var rotationMatrix = Basis.IDENTITY.rotated(Vector3.UP, pivotAngleRad)
		# moving clockwise, add handles 0.5 units away from center of pivot in all 4 directions
		handles.push_back(rotationMatrix * Vector3(pivotDist, 0.5, 0))
		handles.push_back(rotationMatrix * Vector3(pivotDist, 0, 0.5))
		handles.push_back(rotationMatrix * Vector3(pivotDist, -0.5, 0))
		handles.push_back(rotationMatrix * Vector3(pivotDist, 0, -0.5))

	gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _begin_handle_action(gizmo, handleId, isSecondary):
	
	pass
