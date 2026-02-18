extends AnimatableBody3D
class_name Stairs

@onready var initialParent = get_parent()
@onready var initialTransform = Transform3D(transform)

func reset() -> void:
	reparent(initialParent, false)
	transform = initialTransform
