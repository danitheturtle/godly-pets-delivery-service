extends Node3D
class_name Main

@onready var viewport = get_tree().root
@onready var mainMenu = $MainMenu
@onready var pauseMenu = $PauseMenu
@onready var levelSelectMenu = $LevelSelectMenu

func _ready() -> void:
    mainMenu.start_game_pressed.connect(new_game)
    pauseMenu.goto_main_menu.connect(main_menu)
    SignalBus.level_restarted.connect(restart_level)
    SignalBus.reset_to_checkpoint.connect(reset_to_checkpoint)
    SignalBus.game_exited.connect(quit_game)
    SignalBus.game_unpaused.connect(continue_game)
    SignalBus.game_paused.connect(pause_menu)
    SignalBus.level_select_opened.connect(level_select_menu)
    SignalBus.level_selected.connect(goto_level)
    # debug
    new_game()

func main_menu() -> void:
    get_tree().paused = false
    pauseMenu.hide()
    mainMenu.show()

func new_game() -> void:
    mainMenu.hide()
    if State.world != null:
        State.world.free()
    State.reinit()
    var world1 = State.worlds[1].instantiate()
    get_tree().root.add_child.call_deferred(world1)

func quit_game() -> void:
    get_tree().quit()

func continue_game() -> void:
    get_tree().paused = false
    pauseMenu.hide()
    levelSelectMenu.hide()
    State.player.capture_mouse()

func restart_level() -> void:
    continue_game()
    State.level.restart_level()

func reset_to_checkpoint() -> void:
    continue_game()
    State.lastCheckpoint.reset_to_checkpoint()

func pause_menu() -> void:
    get_tree().paused = true
    levelSelectMenu.hide()
    pauseMenu.show()

func level_select_menu() -> void:
    get_tree().paused = true
    pauseMenu.hide()
    levelSelectMenu.show()

func goto_level(worldNumber: int, levelNumber: int) -> void:
    var loadedWorld = State.world
    if worldNumber != State.world.worldNumber && State.world != null:
        State.world.free()
        loadedWorld = State.worlds[worldNumber].instantiate()
        get_tree().root.add_child(loadedWorld)
    var selectedLevel = loadedWorld.get_level(levelNumber)
    selectedLevel.restart_level()
    continue_game()
