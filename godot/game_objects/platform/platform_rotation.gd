class_name PlatformRotation

class RotationState:
    var active: bool = false # toggle between static / animating state
    var cancelled: bool = false # cancellation state
    var queued: int = 0 # player input queue
    var storedIndex: int = 0 # used for soft/hard reset
    var currentIndex: int = 0 # current stop index, updated continuously
    var currentRotationRad: float = 0.0 # offset in radians from current index
    var startIndex: int = 0 # used during rotation
    var targetIndex: int = 0 # used during rotation
    var startPosRad: float = 0.0 # start position along rotation in radians
    var distFromStartRad: float = 0.0 # current rotation relative to startPos
    var targetRotationRad: float = 0.0 # target rotation relative to startPosRad
    var timer: float = 0.0 # rotation animation timer
    var stops: int = 4 # runtime constant
    var radPerStop: float = 0.0 # rotation in radians per stop
    var timerLength: float = 1.0 # runtime constant
    # constructor
    func _init(_stops: int, _timerLength: float) -> void:
        stops = _stops
        timerLength = _timerLength
        radPerStop = TAU / _stops
    # reset state
    func reset() -> void:
        active = false
        cancelled = false
        queued = 0
        timer = 0.0
        startIndex = currentIndex
        startPosRad = radPerStop * startIndex
        targetIndex = currentIndex
        distFromStartRad = 0.0
        targetRotationRad = 0.0

var platform: Platform
var rotationState: RotationState
var pivotsState: RotationState

func _init(_stops: int, _pivotStops: int, _secsPerRotation: float, _secsPerPivot: float, _platform: Platform) -> void:
    platform = _platform
    rotationState = RotationState.new(_stops, _secsPerRotation)
    pivotsState = RotationState.new(_pivotStops, _secsPerPivot)

func update(delta: float) -> void:
    if rotationState.active:
        if rotationState.timer >= rotationState.timerLength:
            finish_rotation(rotationState)
        else:
            update_rotation(delta, rotationState)
    if pivotsState.active:
        if pivotsState.timer >= pivotsState.timerLength:
            finish_rotation(pivotsState)
        else:
            update_rotation(delta, pivotsState)

func reset(hard: bool) -> void:
    rotationState.reset()
    rotationState.currentIndex = 0 if hard else rotationState.storedIndex
    pivotsState.reset()
    pivotsState.currentIndex = 0 if hard else pivotsState.storedIndex

func start_rotation(s: RotationState) -> void:
    s.reset()
    s.active = true

func update_rotation(delta: float, s: RotationState) -> void:
    s.timer += delta
    var posInAnimation = Utils.easeInOutCubic(Utils.normf(s.timer, 0.0, s.timerLength))
    # travel x distance in n time where x is distance between currentPos and targetPos and n is remaining time
    var rotationDiff = absf(s.targetRotationRad) - absf(s.distFromStartRad)
    var remainingRotation = rotationDiff
    if s.targetRotationRad < 0:
        remainingRotation *= -1
    var nextRotationDelta = remap(posInAnimation, 0.0, 1.0, 0.0, absf(remainingRotation))
    s.distFromStartRad += nextRotationDelta
    var nextRotationPos = s.startPosRad + s.distFromStartRad
    if nextRotationDelta >= 0.0:
        if nextRotationPos >= 0.0:
            s.currentIndex = wrapi(floor(nextRotationPos / s.radPerStop), 0, s.stops)
        else:
            s.currentIndex = wrapi(ceil(nextRotationPos / s.radPerStop), 0, s.stops)
    else:
        if nextRotationPos >= 0.0:
            s.currentIndex = wrapi(ceil(nextRotationPos / s.radPerStop), 0, s.stops)
        else:
            s.currentIndex = wrapi(floor(nextRotationPos / s.radPerStop), 0, s.stops)
    s.currentRotationRad = fmod(s.distFromStartRad, s.radPerStop)

func finish_rotation(s: RotationState) -> void:
    s.active = false
    s.currentIndex = s.targetIndex

func apply_rotation_input(dir: int, s: RotationState) -> void:
    # increment / decrement queued rotation, clamp at stops
    s.queued = clampi(s.queued + dir, -(s.stops-1), s.stops-1)
    # update target index and rotation position
    s.targetIndex = wrapi(s.startIndex + s.queued, 0, s.stops)
    s.targetRotationRad = s.queued * s.radPerStop

func on_collision() -> bool:
    if rotationState.active && !rotationState.cancelled:
        rotationState.cancelled = true
        # TODO - Reverse to last safe index
        platform.platform_rotation_cancelled.emit()
        return true
    if pivotsState.active && !pivotsState.cancelled:
        pivotsState.cancelled = true
        # TODO - reverse to last safe index
        platform.stairs_pivot_cancelled.emit()
        return true
    return false

func on_checkpoint_reached() -> void:
    rotationState.storedIndex = rotationState.currentIndex
    pivotsState.storedIndex = pivotsState.currentIndex

func on_unhandled_key_input(event: InputEvent) -> bool:
    var inputDirection = 0
    var pInputDirection = 0
    var rotationUpdates = false
    var pivotsUpdates = false
    if (event.is_action_pressed("rotate_clockwise", false, true)):
        inputDirection = 1
        rotationUpdates = true
    if (event.is_action_pressed("rotate_counter_clockwise", false, true)):
        inputDirection = -1
        rotationUpdates = true
    if (event.is_action_pressed("rotate_pivots_clockwise", false, true)):
        pInputDirection = 1
        pivotsUpdates = true
    if (event.is_action_pressed("rotate_pivots_counter_clockwise", false, true)):
        pInputDirection = -1
        pivotsUpdates = true
    if rotationUpdates:
        if !rotationState.active:
            start_rotation(rotationState)
            platform.on_rotation_started()
        apply_rotation_input(inputDirection, rotationState)
    if pivotsUpdates:
        if !pivotsState.active:
            start_rotation(pivotsState)
            platform.on_pivot_started()
        apply_rotation_input(pInputDirection, pivotsState)
    return rotationUpdates || pivotsUpdates
