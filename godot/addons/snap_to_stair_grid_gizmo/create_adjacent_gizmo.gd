@tool
extends EditorNode3DGizmoPlugin

const PlatformResource = preload("res://scenes/platform/square_platform.tscn")

var pluginRef = null

func _get_gizmo_name() -> String:
	return "SnapGizmo"

func _init():
	# todo make it look better
	create_material("main", Color(1,0,0))
	create_handle_material("handles")

func _has_gizmo(node):
	if (node is Platform):
		return true
	return false

func _redraw(gizmo):
	gizmo.clear()
	var stairGridState = pluginRef.stairGridState
	var editedNode = gizmo.get_node_3d()
	var handles = PackedVector3Array()
	# repeat for each pivot
	var pivotAngleRad: float = 0.0
	var pivotDist = stairGridState.platformSideLength / 2
	# pivots incremented clockwise starting with negative Z (forward)
	for i in range(stairGridState.platformSideCount):
		pivotAngleRad = -i * (TAU / stairGridState.platformSideCount)
		var rotationMatrix = Basis.IDENTITY.rotated(Vector3.UP, pivotAngleRad)
		# moving clockwise, add handles 0.5 units away from center of pivot in all 4 directions
		handles.push_back(rotationMatrix * Vector3(0, 0.5, -pivotDist))
		handles.push_back(rotationMatrix * Vector3(-0.5, 0, -pivotDist))
		handles.push_back(rotationMatrix * Vector3(0, -0.5, -pivotDist))
		handles.push_back(rotationMatrix * Vector3(0.5, 0, -pivotDist))
		pass
	gizmo.add_handles(handles, get_material("handles", gizmo), [])

func _get_handle_name(gizmo, handleId, isSecondary):
	var stairGridState = pluginRef.stairGridState
	return "Pivot " + str(floor(handleId / stairGridState.platformSideCount)) + " Pos " + str(handleId % 4)

# handleId is order in which it was added
func _commit_handle(gizmo, handleId, isSecondary, restore, cancel):
	var stairGridState = pluginRef.stairGridState
	
	# TODO: add undo/redo
	#var _undoRedo = pluginRef.get_undo_redo()
	
	# calculate next platform location based on handle index
	var handleIndex = handleId % 4
	var nextPlatformOrigin = Vector3(0,0,-stairGridState.stairSlopeRun - stairGridState.platformSideLength)
	if handleIndex == 0:
		nextPlatformOrigin.y = stairGridState.stairSlopeRise
	elif handleIndex == 2:
		nextPlatformOrigin.y = -1 * stairGridState.stairSlopeRise
	if handleIndex == 1:
		nextPlatformOrigin.x = -1 * stairGridState.stairSlopeRise
	elif handleIndex == 3:
		nextPlatformOrigin.x = stairGridState.stairSlopeRise
	# get index of pivot
	var pivotIndex = floor(handleId / stairGridState.platformSideCount)
	var pivotAngleRad = -pivotIndex * (TAU / stairGridState.platformSideCount)
	var pivotTransformMatrix = Basis.IDENTITY.rotated(Vector3.UP, pivotAngleRad)
	# create new platform, set its origin
	var editedNode = gizmo.get_node_3d()
	var newPlatform = PlatformResource.instantiate()
	nextPlatformOrigin = pivotTransformMatrix * nextPlatformOrigin + editedNode.transform.origin
	newPlatform.transform.origin = nextPlatformOrigin
	# add new platform to active scene
	var sceneRoot = EditorInterface.get_edited_scene_root()
	sceneRoot.add_child(newPlatform)
	newPlatform.owner = sceneRoot
