extends Control
class_name RotationProgressBar

const ROTATION_OFFSET = -PI/2
var state: PlatformRotationController = null
var relativeRotation: bool = false
var strokeWidth: float = 20.0
var progressColor: Color = Color("#68b603")

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
    if state != null && state.active:
        visible = true
        queue_redraw()
    elif visible:
        visible = false

func _draw() -> void:
    if state == null: return
    var center = Vector2(0,0)
    var radius = (get_parent().size.x - strokeWidth) / 2
    var startAngle = 0.0
    var endAngle = 0.0
    if relativeRotation:
        startAngle = state.startPosRad
        endAngle = state.startPosRad + (state.distToTargetRad - state.distFromStartRad)
    else:
        startAngle = state.startPosRad + state.distFromStartRad
        endAngle = state.startPosRad + state.distToTargetRad
    draw_arc(center, radius, startAngle + ROTATION_OFFSET, endAngle + ROTATION_OFFSET, 30, progressColor, strokeWidth, true)
