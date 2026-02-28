extends CanvasLayer
class_name PauseMenu

signal continue_game
#signal restart_level
signal reset_to_checkpoint
signal goto_main_menu

@onready var continueButton = $CenterContainer/VBoxContainer/ContinueButton
#@onready var restartLevelButton = $CenterContainer/VBoxContainer/RestartLevelButton
@onready var resetToCheckpoint = $CenterContainer/VBoxContainer/ResetToCheckpointButton
#@onready var levelSelectButton = $CenterContainer/VBoxContainer/LevelSelectButton
#@onready var settingsButton = $CenterContainer/VBoxContainer/SettingsButton
@onready var mainMenuButton = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quitButton = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
    continueButton.button_up.connect(_continue_pressed)
    resetToCheckpoint.button_up.connect(_reset_to_checkpoint_pressed)
    mainMenuButton.button_up.connect(_main_menu_pressed)
    quitButton.button_up.connect(_quit_pressed)

func handle_key_input(event: InputEvent ) -> void:
    var eventHandled = false
    if (event.is_action_pressed("ui_close_dialog")):
        continue_game.emit()
    if (eventHandled):
        get_tree().root.set_input_as_handled()

func _continue_pressed() -> void:
    continue_game.emit()
    
func _reset_to_checkpoint_pressed() -> void:
    reset_to_checkpoint.emit()

func _main_menu_pressed() -> void:
    goto_main_menu.emit()

func _quit_pressed() -> void:
    SignalBus.game_exited.emit()
