extends SubViewport
class_name RotationProgressViewport

@export var strokeWidth: float = 20.0
@export var progressColor: Color = Color("#68b603")
@export var relativeRotation: bool = false
@onready var progressBar: RotationProgressBar = $CenterContainer/ProgressBar

var state: PlatformRotationController = null

func set_tracked_state(_state: PlatformRotationController):
    state = _state
    progressBar.state = state
    progressBar.relativeRotation = relativeRotation
    progressBar.strokeWidth = strokeWidth
    progressBar.progressColor = progressColor
