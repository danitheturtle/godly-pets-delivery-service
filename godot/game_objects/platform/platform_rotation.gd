class_name PlatformRotation

class RotationState:
    # constant after init
    var timerLength: float = 1.0
    var stops: int = 4
    var radPerStop: float = 0.0 # rotation in radians per stop
    # state
    var active: bool = false # toggle between static / animating state
    var cancelled: bool = false # cancellation state
    var queued: int = 0 # player input queue
    var timer: float = 0.0 # rotation animation timer
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
    # constructor
    func _init(_stops: int, _timerLength: float) -> void:
        stops = _stops
        timerLength = _timerLength
        radPerStop = TAU / _stops
    # reset state
    func reset(hard: bool) -> void:
        active = false
        cancelled = false
        queued = 0
        timer = 0.0
        currentIndex = 0 if hard else storedIndex
        startIndex = currentIndex
        targetIndex = currentIndex
        currentPosRad = currentIndex * radPerStop
        startPosRad = currentPosRad
        targetPosRad = currentPosRad
        distFromStartRad = 0.0
        distToTargetRad = 0.0

var platform: Platform
var rotationState: RotationState
var pivotsState: RotationState

func _init(_stops: int, _pivotStops: int, _secsPerRotation: float, _secsPerPivot: float, _platform: Platform) -> void:
    platform = _platform
    rotationState = RotationState.new(_stops, _secsPerRotation)
    pivotsState = RotationState.new(_pivotStops, _secsPerPivot)

func update(delta: float) -> void:
    if rotationState.active:
        var finished = update_rotation(delta, rotationState)
        if finished:
            finish_rotation(rotationState)
            platform.on_rotation_finished()
    if pivotsState.active:
        var finished = update_rotation(delta, pivotsState)
        if finished:
            finish_rotation(pivotsState)
            platform.on_pivot_finished()

func reset(hard: bool) -> void:
    rotationState.reset(hard)
    pivotsState.reset(hard)

func start_rotation(s: RotationState) -> void:
    s.active = true
    s.cancelled = false

func finish_rotation(s: RotationState) -> void:
    s.active = false
    s.queued = 0
    s.timer = 0.0
    s.currentIndex = s.targetIndex
    s.startIndex = s.targetIndex
    s.currentPosRad = s.targetPosRad
    s.startPosRad = s.targetPosRad
    s.distFromStartRad = 0.0
    s.distToTargetRad = 0.0

func update_rotation(delta: float, s: RotationState) -> bool:
    s.timer += delta
    var posInAnimation = Utils.easeInOutCubic(Utils.normf(s.timer, 0.0, s.timerLength))
    var remainingTime = s.timerLength - s.timer
    if (Utils.equalsf(remainingTime, 0.0)): return true
    var remainingUpdates = remainingTime / delta
    var currentToTargetMagnitude = absf(s.distToTargetRad - s.distFromStartRad)
    var currentToTargetDir = 1 if s.distToTargetRad >= s.distFromStartRad else -1
    
    var nextRotationUpdate = currentToTargetDir * currentToTargetMagnitude / remainingUpdates
    
    s.distFromStartRad += nextRotationUpdate
    s.currentPosRad = wrapf(s.startPosRad + s.distFromStartRad, 0.0, TAU)
    if currentToTargetDir >= 0:
        s.currentIndex = floori(s.currentPosRad / s.radPerStop)
    else:
        s.currentIndex = ceili(s.currentPosRad / s.radPerStop)
    return false

func apply_rotation_input(dir: int, s: RotationState) -> void:
    # increment / decrement queued rotation, clamp at stops
    s.queued = clampi(s.queued + dir, -s.stops, s.stops)
    # update target index and rotation position
    s.targetIndex = wrapi(s.startIndex + s.queued, 0, s.stops)
    s.targetPosRad = s.targetIndex * s.radPerStop
    s.distToTargetRad = s.queued * s.radPerStop

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
