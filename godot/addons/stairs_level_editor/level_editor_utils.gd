@tool

static func add_to_scene(editedNode: Node3D, newNode: Node3D, transform: Transform3D) -> void:
    newNode.transform = transform
    editedNode.get_parent().add_child(newNode)
    newNode.owner = EditorInterface.get_edited_scene_root()

static func get_rotation_to_pivot_matrix(pivotIndex: int, stops: int) -> Basis:
    var pivotAngleRad = - pivotIndex * (TAU / stops)
    return Basis.IDENTITY.rotated(Vector3.UP, pivotAngleRad)