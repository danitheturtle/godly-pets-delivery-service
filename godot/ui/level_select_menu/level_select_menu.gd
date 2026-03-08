extends CanvasLayer

@onready var levelsMenu = $MarginContainer/VBoxContainer

var worldLabelRefs: Array[Label] = [null] # null padded, world count starts at 1
var levelButtonRefsByWorld: Dictionary[int, Array] = {}

func _ready() -> void:
    SignalBus.level_select_opened.connect(on_level_select_opened)
    init_from_metadata()

func _unhandled_key_input(event: InputEvent) -> void:
    var eventHandled = false
    # handle pause game
    if (visible && event.is_action_pressed("ui_close_dialog")):
        eventHandled = true
        SignalBus.game_unpaused.emit()
    if (eventHandled):
        get_tree().root.set_input_as_handled()

func on_level_select_opened() -> void:
    for nextWorldNum in range(1,State.highestWorldReached+1):
        if !worldLabelRefs[nextWorldNum].visible:
            worldLabelRefs[nextWorldNum].show()
        var levelButtonCount = State.highestLevelReached+1
        if State.highestWorldReached > nextWorldNum:
            levelButtonCount = State.levelCountByWorld[nextWorldNum]+1
        for nextLevelNum in range(1,levelButtonCount):
            if levelButtonRefsByWorld[nextWorldNum][nextLevelNum].disabled:
                levelButtonRefsByWorld[nextWorldNum][nextLevelNum].disabled = false
                levelButtonRefsByWorld[nextWorldNum][nextLevelNum].show()

func get_on_level_button_clicked(_worldNumber: int, _levelNumber: int):
    return func (): SignalBus.level_selected.emit(_worldNumber, _levelNumber)

# to avoid having to edit this menu every time a level is added (and to support mods), programatically generate
# TODO: Custom scenes for buttons/labels to make things look fancy
func init_from_metadata() -> void:
    for _worldNum in range(1,State.worlds.size()+1):
        # create new label for world and add it to levels menu. hidden by default
        var worldLabel = Label.new()
        worldLabel.text = "World " + str(_worldNum)
        worldLabel.hide()
        worldLabelRefs.append(worldLabel)
        levelsMenu.add_child(worldLabel)
        # create level buttons for world based on world level count
        levelButtonRefsByWorld.set(_worldNum, [null]) # null padded, level count starts at 1
        var levelsContainer = HFlowContainer.new()
        for _levelNum in range(1,State.levelCountByWorld[_worldNum]+1):
            # create new button for level and add to levels menu. disabled/hidden by default
            var levelButton = Button.new()
            levelButton.text = "Level " + str(_levelNum)
            levelButton.hide()
            levelButton.disabled = true
            levelButtonRefsByWorld.get(_worldNum).append(levelButton)
            # connect button to signal bus
            levelButton.button_up.connect(get_on_level_button_clicked(_worldNum, _levelNum))
            levelsContainer.add_child(levelButton)
        levelsMenu.add_child(levelsContainer)
