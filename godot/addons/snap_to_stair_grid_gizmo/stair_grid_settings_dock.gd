@tool
extends VFlowContainer
class_name StairGridSettingsDock
# bind inputs to the global state so values can be read by gizmos
@onready var modeSwitch = $Scroll/VBox/ModeSwitchHBox/ModeSwitch
@onready var platformResource = $Scroll/VBox/PlatformTypeHBox/PlatformTypeOptionButton
@onready var puzzlePieceResource = $Scroll/VBox/PuzzlePieceTypeHBox/PuzzlePieceTypeOptionButton
@onready var platformSideLengthInput = $Scroll/VBox/PlatformPropsHBox/SideLengthSpinBox
@onready var platformSideCountInput = $Scroll/VBox/PlatformPropsHBox/SideCountSpinBox
@onready var stairSlopeRise = $Scroll/VBox/StairsSlopeHBox/StairsRiseSpinBox
@onready var stairSlopeRun = $Scroll/VBox/StairsSlopeHBox/StairsRunSpinBox

var pluginRef = null
var stairGridState = {}

func _ready() -> void:
    if (pluginRef != null):
        modeSwitch.toggled.connect(pluginRef.on_mode_switch_toggled)
        platformResource.item_selected.connect(pluginRef.on_platform_resource_selected)
        puzzlePieceResource.item_selected.connect(pluginRef.on_puzzle_piece_resource_selected)
        platformSideLengthInput.value_changed.connect(pluginRef.on_platform_side_length_changed)
        platformSideCountInput.value_changed.connect(pluginRef.on_platform_side_count_changed)
        stairSlopeRise.value_changed.connect(pluginRef.on_stair_slope_rise_changed)
        stairSlopeRun.value_changed.connect(pluginRef.on_stair_slope_run_changed)
        initializeFromState(stairGridState)

func setup(_pluginRef, _stairGridState) -> void:
    pluginRef = _pluginRef
    stairGridState = _stairGridState

func initializeFromState(stairGridState) -> void:
    platformSideLengthInput.set_value_no_signal(stairGridState.platformSideLength)
    platformSideCountInput.set_value_no_signal(stairGridState.platformSideCount)
    stairSlopeRise.set_value_no_signal(stairGridState.stairSlopeRise)
    stairSlopeRun.set_value_no_signal(stairGridState.stairSlopeRun)
