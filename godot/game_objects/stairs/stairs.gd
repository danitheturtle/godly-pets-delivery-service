extends AnimatableBody3D
class_name Stairs

@onready var initialParent = get_parent()
@onready var initialTransform = Transform3D(transform)

var storedParent
var storedTransform

func _ready() -> void:
	storedParent = initialParent
	storedTransform = initialTransform
	# listen for checkpoints
	SignalBus.checkpoint_activated.connect(_checkpoint_reached)

func reset(hard: bool = false) -> void:
	if (!hard):
		reparent(storedParent, false)
		transform = storedTransform
	else:
		reparent(initialParent, false)
		transform = initialTransform

func _checkpoint_reached() -> void:
	storedParent = get_parent()
	storedTransform = Transform3D(transform)
