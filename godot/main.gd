extends Node3D
class_name Main

@onready var mainMenu = $MainMenu
@onready var pauseMenu = $PauseMenu

const World1Resource = preload("res://worlds/world_1.tscn")

func _ready() -> void:
    mainMenu.start_game_pressed.connect(new_game)
    pauseMenu.continue_game.connect(continue_game)
    pauseMenu.reset_to_checkpoint.connect(reset_to_checkpoint)
    pauseMenu.goto_main_menu.connect(main_menu)
    SignalBus.game_exited.connect(quit_game)
    SignalBus.game_paused.connect(pause_game)

func main_menu() -> void:
    get_tree().paused = false
    pauseMenu.hide()
    mainMenu.show()

func new_game() -> void:
    mainMenu.hide()
    if State.loadedWorld != null:
        State.loadedWorld.free()
    State.reinit()
    var world1 = World1Resource.instantiate()
    get_tree().root.add_child(world1)

func quit_game() -> void:
    get_tree().quit()

func pause_game() -> void:
    get_tree().paused = true
    pauseMenu.show()

func continue_game() -> void:
    get_tree().paused = false
    pauseMenu.hide()
    Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_CAPTURED)
    if State.player is Player:
        State.player.mouseCaptured = true

func reset_to_checkpoint() -> void:
    continue_game()
    if State.lastCheckpoint is Checkpoint:
        State.lastCheckpoint.reset_to_checkpoint()
