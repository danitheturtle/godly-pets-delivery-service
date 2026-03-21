class_name PlatformRotationController

# constant after init
var timerLength: float
var minTimePerStop: float # minimum time it takes to rotate through 1 stop
var stops: int
var radPerStop: float # rotation in radians per stop
var clockwiseAction: String
var counterClockwiseAction: String
# state
var active: bool = false # toggle between static / animating state
var cancelled: bool = false # cancellation state
var queued: int = 0 # player input queue
var timer: float = 0.0 # rotation animation timer
var minTimerLength: float = 0.0
# rotation indices
var storedIndex: int = 0 # used for soft/hard reset
var currentIndex: int = 0 # current stop index, updated continuously
var startIndex: int = 0 # used during rotation
var targetIndex: int = 0 # used during rotation
# rotation radians
var startPosRad: float = 0.0 # start position along rotation in radians from 0 - TAU
var currentPosRad: float = 0.0 # current position along rotation in radians from 0 - TAU
var targetPosRad: float = 0.0 # target position along rotation in radians from 0 - TAU
var distFromStartRad: float = 0.0 # current rotation relative to startPos from -TAU to TAU
var distToTargetRad: float = 0.0 # target rotation relative to startPosRad from -TAU to TAU
var currentToTargetDir: int = 0 # direction of rotation

var previousIndex: int = 0
var previousPosRad: float = 0.0
var previousAnimationPos: float = 0.0

func _init(_stops: int, _timerLength: float, _minTimePerStop: float, _clockwiseAction: String, _counterClockwiseAction: String) -> void:
    timerLength = _timerLength
    minTimerLength = _timerLength
    stops = _stops
    minTimePerStop = _minTimePerStop
    radPerStop = TAU / _stops
    clockwiseAction = _clockwiseAction
    counterClockwiseAction = _counterClockwiseAction

func update(delta: float) -> bool:
    if active:
        if update_rotation(delta):
            finish_rotation()
            return true
    return false

func reset(hard: bool) -> void:
    active = false
    cancelled = false
    queued = 0
    timer = 0.0
    minTimerLength = timerLength
    previousAnimationPos = 0.0
    currentIndex = 0 if hard else storedIndex
    previousIndex = currentIndex
    startIndex = currentIndex
    targetIndex = currentIndex
    currentPosRad = currentIndex * radPerStop
    startPosRad = currentPosRad
    targetPosRad = currentPosRad
    distFromStartRad = 0.0
    distToTargetRad = 0.0

func finish_rotation() -> void:
    active = false
    cancelled = false
    queued = 0
    timer = 0.0
    previousAnimationPos = 0.0
    currentIndex = targetIndex
    startIndex = targetIndex
    currentPosRad = targetPosRad
    startPosRad = targetPosRad
    distFromStartRad = 0.0
    distToTargetRad = 0.0

func update_rotation(delta: float) -> bool:
    previousIndex = currentIndex
    previousPosRad = currentPosRad
    timer += delta
    var posInAnimation = get_animation_position()
    var remainingTime = minTimerLength - timer
    # early exit if animation is finished
    if (Utils.equalsf(remainingTime, 0.0)):
        return true
    var currentToTargetMagnitude = absf(distToTargetRad - distFromStartRad)
    currentToTargetDir = 1 if distToTargetRad >= distFromStartRad else -1
    var nextRotationUpdate = currentToTargetDir * remap(posInAnimation, previousAnimationPos, 1.0, 0.0, currentToTargetMagnitude)
    distFromStartRad += nextRotationUpdate
    currentPosRad = wrapf(startPosRad + distFromStartRad, 0.0, TAU)
    if currentToTargetDir >= 0:
        currentIndex = wrapi(floor(currentPosRad / radPerStop), 0, stops)
    else:
        currentIndex = wrapi(ceil(currentPosRad / radPerStop), 0, stops)
    previousAnimationPos = posInAnimation
    return false

func apply_rotation_input(dir: int) -> void:
    # increment / decrement queued rotation, clamp at stops
    queued = clampi(queued + dir, -stops, stops)
    # update target index and rotation position
    targetIndex = wrapi(startIndex + queued, 0, stops)
    targetPosRad = targetIndex * radPerStop
    distToTargetRad = queued * radPerStop
    # cap time left so platform doesn't snap
    minTimerLength = max(minTimePerStop * abs(queued), timerLength)
    clamp_to_min_timer()
    previousAnimationPos = get_animation_position()

func get_animation_position() -> float:
    return Utils.easeInOutCubic(Utils.normf(timer, 0.0, minTimerLength))

func clamp_to_min_timer() -> void:
    if minTimerLength - timer < minTimePerStop:
        timer = minTimerLength - minTimePerStop

func on_collision() -> bool:
    if active && !cancelled:
        cancelled = true
        startIndex = wrapi(previousIndex + currentToTargetDir, 0, stops)
        targetIndex = previousIndex
        startPosRad = startIndex * radPerStop
        targetPosRad = targetIndex * radPerStop
        currentToTargetDir *= -1
        distToTargetRad = radPerStop * currentToTargetDir
        distFromStartRad = previousPosRad - (startPosRad if !Utils.equalsf(startPosRad, 0.0) else TAU)
        clamp_to_min_timer()
        previousAnimationPos = get_animation_position()
        return true
    return false

func on_checkpoint_reached() -> void:
    storedIndex = currentIndex

func on_unhandled_key_input(event: InputEvent) -> String:
    var inputDirection = 0
    var rotationUpdates = false
    var rotationStarted = false
    if (event.is_action_pressed(clockwiseAction, false, true)):
        inputDirection = 1
        rotationUpdates = true
    if (event.is_action_pressed(counterClockwiseAction, false, true)):
        inputDirection = -1
        rotationUpdates = true
    rotationUpdates = rotationUpdates && !cancelled
    if rotationUpdates:
        if !active:
            active = true
            rotationStarted = true
        apply_rotation_input(inputDirection)
    if rotationStarted: return "rotation_started"
    return "handled" if rotationUpdates else "unhandled"
