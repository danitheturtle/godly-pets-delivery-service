@tool
extends EditorNode3DGizmoPlugin

const PlatformResource = preload("res://scenes/platform/square_platform.tscn")
const StairsResource = preload("res://scenes/stairs/stairs.tscn")

var pluginRef = null
var stairGridState = {}

func _get_gizmo_name() -> String:
	return "SnapGizmo"

func _init():
	# todo make it look better
	create_material("main", Color(1,0,0))
	create_handle_material("handles")

func setup(_pluginRef, _stairGridState):
	pluginRef = _pluginRef
	stairGridState = _stairGridState

func _has_gizmo(node):
	if (node is Platform):
		return true
	return false

func _redraw(gizmo):
	gizmo.clear()
	var editedNode = gizmo.get_node_3d()
	var handles = PackedVector3Array()
	# repeat for each pivot
	var pivotAngleRad: float = 0.0
	var pivotDist = stairGridState.platformSideLength / 2
	# pivots incremented clockwise starting with negative Z (forward)
	for i in range(stairGridState.platformSideCount):
		var rotationToPivot = get_rotation_to_pivot_matrix(i)
		# moving clockwise, add handles 0.5 units away from center of pivot in all 4 directions
		handles.push_back(rotationToPivot * Vector3(0, 0.5, -pivotDist))
		handles.push_back(rotationToPivot * Vector3(0.5, 0, -pivotDist))
		handles.push_back(rotationToPivot * Vector3(0, -0.5, -pivotDist))
		handles.push_back(rotationToPivot * Vector3(-0.5, 0, -pivotDist))
		pass
	gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary):
	return "Pivot " + str(floor(handleId / stairGridState.platformSideCount)) + " Pos " + str(handleId % 4)

# handleId is order in which it was added
func _commit_handle(gizmo, handleId, isSecondary, restore, cancel):
	var sceneRoot = EditorInterface.get_edited_scene_root()
	var editedNode = gizmo.get_node_3d()
	
	var handleIndex = handleId % 4
	var pivotIndex = floor(handleId / stairGridState.platformSideCount)
	
	# TODO: add undo/redo
	#var _undoRedo = pluginRef.get_undo_redo()
	
	var rotationToPivot = get_rotation_to_pivot_matrix(pivotIndex)
	if stairGridState.placementMode == "platforms":
		var newPlatform = PlatformResource.instantiate()
		var newPlatformTransform = get_next_platform_transform(handleIndex, pivotIndex)
		newPlatformTransform.origin = rotationToPivot * newPlatformTransform.origin + editedNode.transform.origin
		newPlatform.transform = newPlatformTransform
		editedNode.get_parent().add_child(newPlatform)
		newPlatform.owner = sceneRoot
	elif stairGridState.placementMode == "stairs":
		var newStairs = StairsResource.instantiate()
		var newStairsTransform = get_next_stair_transform(handleIndex, pivotIndex)
		newStairsTransform.origin = rotationToPivot * newStairsTransform.origin + editedNode.transform.origin
		newStairsTransform.basis = rotationToPivot * newStairsTransform.basis
		newStairs.transform = newStairsTransform
		editedNode.get_parent().add_child(newStairs)
		newStairs.owner = sceneRoot

func get_next_platform_transform(handleIndex: int, pivotIndex: int):
	var nextPlatformTransform = Transform3D(
		Basis.IDENTITY,
		Vector3(0,0,-stairGridState.stairSlopeRun - stairGridState.platformSideLength)
	)
	match handleIndex:
		0:
			nextPlatformTransform.origin.y = stairGridState.stairSlopeRise
		1:
			nextPlatformTransform.origin.x = stairGridState.stairSlopeRise
		2:
			nextPlatformTransform.origin.y = -1 * stairGridState.stairSlopeRise
		3:
			nextPlatformTransform.origin.x = -1 * stairGridState.stairSlopeRise
	return nextPlatformTransform

func get_next_stair_transform(handleIndex: int, pivotIndex: int):
	var nextStairTransform = Transform3D(
		Basis.IDENTITY, 
		Vector3(0,0,-stairGridState.stairSlopeRun / 2 - stairGridState.platformSideLength / 2)
	)
	match handleIndex:
		0:
			nextStairTransform.origin.y = stairGridState.stairSlopeRise / 2
		1:
			nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, PI / 2)
			nextStairTransform.origin.x = stairGridState.stairSlopeRise / 2
		2:
			nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, PI)
			nextStairTransform.origin.y = -stairGridState.stairSlopeRise / 2
		3:
			nextStairTransform.basis = nextStairTransform.basis.rotated(Vector3.FORWARD, -PI / 2)
			nextStairTransform.origin.x = -stairGridState.stairSlopeRise / 2
	return nextStairTransform

func get_rotation_to_pivot_matrix(pivotIndex: int) -> Basis:
	var pivotAngleRad = -pivotIndex * (TAU / stairGridState.platformSideCount)
	return Basis.IDENTITY.rotated(Vector3.UP, pivotAngleRad)
