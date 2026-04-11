@tool
extends VFlowContainer
class_name StairsLevelEditorDock
# bind inputs to the global state so values can be read by gizmos
@onready var modeSwitch = $Scroll/VBox/ModeSwitchHBox/ModeSwitch
@onready var platformResource = $Scroll/VBox/PlatformTypeHBox/PlatformTypeOptionButton
@onready var puzzlePieceResource = $Scroll/VBox/PuzzlePieceTypeHBox/PuzzlePieceTypeOptionButton
@onready var platformSideLengthInput = $Scroll/VBox/PlatformPropsHBox/SideLengthSpinBox
@onready var platformSideCountInput = $Scroll/VBox/PlatformPropsHBox/SideCountSpinBox
@onready var stairsRise = $Scroll/VBox/StairsSlopeHBox/StairsRiseSpinBox
@onready var stairsRun = $Scroll/VBox/StairsSlopeHBox/StairsRunSpinBox

var pluginRef = null
var pluginState = {}
var shortcut: Shortcut = null

func _ready() -> void:
    if (pluginRef != null):
        modeSwitch.toggled.connect(pluginRef.on_mode_switch_toggled)
        platformResource.item_selected.connect(pluginRef.on_platform_resource_selected)
        puzzlePieceResource.item_selected.connect(pluginRef.on_puzzle_piece_resource_selected)
        platformSideLengthInput.value_changed.connect(pluginRef.on_platform_side_length_changed)
        platformSideCountInput.value_changed.connect(pluginRef.on_platform_side_count_changed)
        stairsRise.value_changed.connect(pluginRef.on_stair_slope_rise_changed)
        stairsRun.value_changed.connect(pluginRef.on_stair_slope_run_changed)
        shortcut = EditorInterface.get_editor_settings().get_shortcut("stairs_level_editor/editor_mode_switch")
        initializeFromState(pluginState)

func _shortcut_input(event: InputEvent) -> void:
    var eventHandled: bool = false
    if (shortcut != null && shortcut.matches_event(event)):
        modeSwitch.button_pressed = !modeSwitch.button_pressed
        eventHandled = true
    if (eventHandled):
        get_tree().root.set_input_as_handled()

func setup(_pluginRef, _pluginState) -> void:
    pluginRef = _pluginRef
    pluginState = _pluginState

func initializeFromState(pluginState) -> void:
    platformSideLengthInput.set_value_no_signal(pluginState.platformSideLength)
    platformSideCountInput.set_value_no_signal(pluginState.platformSideCount)
    stairsRise.set_value_no_signal(pluginState.stairsRise)
    stairsRun.set_value_no_signal(pluginState.stairsRun)
