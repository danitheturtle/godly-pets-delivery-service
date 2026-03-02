extends CanvasLayer
class_name PauseMenu

signal continue_game
signal goto_main_menu

@onready var continueButton = $CenterContainer/VBoxContainer/ContinueButton
@onready var restartLevelButton = $CenterContainer/VBoxContainer/RestartLevelButton
@onready var resetToCheckpoint = $CenterContainer/VBoxContainer/ResetToCheckpointButton
#@onready var levelSelectButton = $CenterContainer/VBoxContainer/LevelSelectButton
#@onready var settingsButton = $CenterContainer/VBoxContainer/SettingsButton
@onready var mainMenuButton = $CenterContainer/VBoxContainer/MainMenuButton
@onready var quitButton = $CenterContainer/VBoxContainer/QuitButton

func _ready() -> void:
    continueButton.button_up.connect(on_continue_pressed)
    restartLevelButton.button_up.connect(on_restart_level)
    resetToCheckpoint.button_up.connect(on_reset_to_checkpoint_pressed)
    mainMenuButton.button_up.connect(on_main_menu_pressed)
    quitButton.button_up.connect(on_quit_pressed)

func handle_key_input(event: InputEvent ) -> void:
    var eventHandled = false
    if (event.is_action_pressed("ui_close_dialog")):
        continue_game.emit()
    if (eventHandled):
        get_tree().root.set_input_as_handled()

func on_continue_pressed() -> void:
    continue_game.emit()

func on_restart_level() -> void:
    SignalBus.level_restarted.emit()

func on_reset_to_checkpoint_pressed() -> void:
    SignalBus.reset_to_checkpoint.emit()

func on_main_menu_pressed() -> void:
    goto_main_menu.emit()

func on_quit_pressed() -> void:
    SignalBus.game_exited.emit()
