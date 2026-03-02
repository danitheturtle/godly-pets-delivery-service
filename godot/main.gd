extends Node3D
class_name Main

@onready var viewport = get_tree().root
@onready var mainMenu = $MainMenu
@onready var pauseMenu = $PauseMenu

const World1Resource = preload("res://worlds/world_1.tscn")

func _ready() -> void:
    mainMenu.start_game_pressed.connect(new_game)
    pauseMenu.continue_game.connect(continue_game)
    pauseMenu.goto_main_menu.connect(main_menu)
    SignalBus.level_restarted.connect(restart_level)
    SignalBus.reset_to_checkpoint.connect(reset_to_checkpoint)
    SignalBus.game_exited.connect(quit_game)
    SignalBus.game_paused.connect(pause_game)
    # debug
    #new_game()

func main_menu() -> void:
    get_tree().paused = false
    pauseMenu.hide()
    mainMenu.show()

func new_game() -> void:
    mainMenu.hide()
    if State.world != null:
        State.world.free()
    State.reinit()
    var world1 = World1Resource.instantiate()
    get_tree().root.add_child.call_deferred(world1)

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

func restart_level() -> void:
    continue_game()
    State.level.restart_level()

func reset_to_checkpoint() -> void:
    continue_game()
    State.lastCheckpoint.reset_to_checkpoint()
