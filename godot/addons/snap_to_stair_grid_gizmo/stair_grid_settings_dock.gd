@tool
extends VFlowContainer
# bind inputs to the global state so values can be read by gizmos
@onready var modeSwitch = $Scroll/VBox/ModeSwitchWrapper/ModeSwitch
@onready var gridOriginX = $Scroll/VBox/GridOriginVector/GridOriginX
@onready var gridOriginY = $Scroll/VBox/GridOriginVector/GridOriginY
@onready var gridOriginZ = $Scroll/VBox/GridOriginVector/GridOriginZ
@onready var platformSideLengthInput = $Scroll/VBox/PlatformSideLength
@onready var platformSideCountInput = $Scroll/VBox/PlatformSideCount
@onready var stairSlopeRise = $Scroll/VBox/StairSlopeWrapper/StairRise
@onready var stairSlopeRun = $Scroll/VBox/StairSlopeWrapper/StairRun

func _ready() -> void:
	gridOriginX.set_value_no_signal(StairGridState.gridOrigin.x);
	gridOriginY.set_value_no_signal(StairGridState.gridOrigin.y);
	gridOriginZ.set_value_no_signal(StairGridState.gridOrigin.z);
	platformSideLengthInput.set_value_no_signal(StairGridState.platformSideLength)
	platformSideCountInput.set_value_no_signal(StairGridState.platformSideCount)
	stairSlopeRise.set_value_no_signal(StairGridState.stairSlopeRise)
	stairSlopeRun.set_value_no_signal(StairGridState.stairSlopeRun)
	
	modeSwitch.toggled.connect(_mode_switch_toggled)
	gridOriginX.changed.connect(_grid_origin_x_changed)
	gridOriginY.changed.connect(_grid_origin_y_changed)
	gridOriginZ.changed.connect(_grid_origin_z_changed)
	platformSideLengthInput.changed.connect(_platform_side_length_changed)
	platformSideCountInput.changed.connect(_platform_side_count_changed)
	stairSlopeRise.changed.connect(_stair_slope_rise_changed)
	stairSlopeRun.changed.connect(_stair_slope_run_changed)

func _mode_switch_toggled(toggledOn: bool):
	if (toggledOn):
		StairGridState.placementMode = "platforms"
	else:
		StairGridState.placementMode = "stairs"

func _grid_origin_x_changed(nextX: float):
	StairGridState.gridOrigin.x = nextX
	
func _grid_origin_y_changed(nextY: float):
	StairGridState.gridOrigin.y = nextY

func _grid_origin_z_changed(nextZ: float):
	StairGridState.gridOrigin.z = nextZ

func _platform_side_length_changed(nextLength: float):
	StairGridState.platformSideLength = nextLength

func _platform_side_count_changed(nextCount: int):
	StairGridState.platformSideCount = nextCount

func _stair_slope_rise_changed(nextRise: float):
	StairGridState.stairSlopeRise = nextRise

func _stair_slope_run_changed(nextRun: float):
	StairGridState.stairSlopeRun = nextRun
