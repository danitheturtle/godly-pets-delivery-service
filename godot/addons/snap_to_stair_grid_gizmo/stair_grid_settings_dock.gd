@tool
extends VFlowContainer
class_name StairGridSettingsDock
# bind inputs to the global state so values can be read by gizmos
@onready var modeSwitch = $Scroll/VBox/ModeSwitchWrapper/ModeSwitch
@onready var gridOriginX = $Scroll/VBox/GridOriginVector/GridOriginX
@onready var gridOriginY = $Scroll/VBox/GridOriginVector/GridOriginY
@onready var gridOriginZ = $Scroll/VBox/GridOriginVector/GridOriginZ
@onready var platformSideLengthInput = $Scroll/VBox/PlatformSideLength
@onready var platformSideCountInput = $Scroll/VBox/PlatformSideCount
@onready var stairSlopeRise = $Scroll/VBox/StairSlopeWrapper/StairRise
@onready var stairSlopeRun = $Scroll/VBox/StairSlopeWrapper/StairRun
@onready var tesselatePlatforms = $Scroll/VBox/TesselatePlatformsButton

var pluginRef = null
var stairGridState = {}

func _ready() -> void:
    if (pluginRef != null):
        modeSwitch.toggled.connect(pluginRef._mode_switch_toggled)
        gridOriginX.value_changed.connect(pluginRef._grid_origin_x_changed)
        gridOriginY.value_changed.connect(pluginRef._grid_origin_y_changed)
        gridOriginZ.value_changed.connect(pluginRef._grid_origin_z_changed)
        platformSideLengthInput.value_changed.connect(pluginRef._platform_side_length_changed)
        platformSideCountInput.value_changed.connect(pluginRef._platform_side_count_changed)
        stairSlopeRise.value_changed.connect(pluginRef._stair_slope_rise_changed)
        stairSlopeRun.value_changed.connect(pluginRef._stair_slope_run_changed)
        tesselatePlatforms.button_up.connect(pluginRef._tesselate_platforms_clicked)
        initializeFromState(stairGridState)

func setup(_pluginRef, _stairGridState) -> void:
    pluginRef = _pluginRef
    stairGridState = _stairGridState

func initializeFromState(stairGridState) -> void:
    gridOriginX.set_value_no_signal(stairGridState.gridOrigin.x);
    gridOriginY.set_value_no_signal(stairGridState.gridOrigin.y);
    gridOriginZ.set_value_no_signal(stairGridState.gridOrigin.z);
    platformSideLengthInput.set_value_no_signal(stairGridState.platformSideLength)
    platformSideCountInput.set_value_no_signal(stairGridState.platformSideCount)
    stairSlopeRise.set_value_no_signal(stairGridState.stairSlopeRise)
    stairSlopeRun.set_value_no_signal(stairGridState.stairSlopeRun)
