@tool
extends Node3D
class_name ForceField

# editor only utils
const ForceFieldEditorHelperRes = preload("res://game_objects/force_field/force_field_editor_helper.gd")
var editorHelper: ForceFieldEditorHelper = null

@onready var verticalPlayerEmitter = $VerticalPlayerEmitter
@onready var playerCollider = $VerticalPlayerEmitter/Collider
@onready var playerVisualField = $VerticalPlayerEmitter/VisualField
@onready var horizontalPetEmitter = $HorizontalPetEmitter
@onready var petCollider = $HorizontalPetEmitter/Collider
@onready var petVisualField = $HorizontalPetEmitter/VisualField
@onready var indicatorMesh = $IndicatorMesh

# activator or puzzle wire
@export_category("Activation")
@export var playerFieldActivator: Node = null:
    set(new_value):
        playerFieldActivator = new_value
        if new_value == null: initialPlayerFieldState = false
        if editorHelper != null: enable_player_field(new_value != null)
@export var petFieldActivator: Node = null:
    set(new_value):
        petFieldActivator = new_value
        if new_value == null: initialPlayerFieldState = false
        if editorHelper != null: enable_player_field(new_value != null)
@export var inactiveColor: Color = Color("be8b26") # TODO refactor into color system
@export var activeColor: Color = Color("4b9fce") # TODO refactor into color system
@export_category("Initial State")
@export var initialPlayerFieldState: bool = true:
    set(new_value):
        if playerFieldActivator == null: return
        initialPlayerFieldState = new_value
        if editorHelper != null: player_field_toggle(new_value)
@export var initialPetFieldState: bool = true:
    set(new_value):
        if petFieldActivator == null: return
        initialPetFieldState = new_value
        if editorHelper != null: pet_field_toggle(new_value)
@export_category("Force Field Size")
@export_range(1.0, 100.0, 0.5, "or_greater") var fieldWidth: float = 5.5:
    set(new_value):
        if editorHelper != null: editorHelper.update_field_width(new_value)
        fieldWidth = new_value
@export_range(1.0, 100.0, 0.5, "or_greater") var fieldHeight: float = 5.5:
    set(new_value):
        if editorHelper != null: editorHelper.update_field_height(new_value)
        fieldHeight = new_value

# local state
var active: bool = false
var playerFieldState: bool = true
var petFieldState: bool = true

func _ready() -> void:
    if Engine.is_editor_hint():
        after_ready.call_deferred()
    else:
        enable_player_field(playerFieldActivator != null)
        player_field_toggle(initialPlayerFieldState)
        enable_pet_field(petFieldActivator != null)
        pet_field_toggle(initialPetFieldState)
        if playerFieldActivator != null:
            playerFieldActivator.wire_high.connect(activate_player_field)
            playerFieldActivator.wire_low.connect(deactivate_player_field)
        else:
            verticalPlayerEmitter.free()
        if petFieldActivator != null:
            playerFieldActivator.wire_high.connect(activate_player_field)
            playerFieldActivator.wire_low.connect(deactivate_player_field)
        else:
            horizontalPetEmitter.free()
    playerFieldState = playerFieldActivator != null && initialPlayerFieldState
    petFieldState = petFieldActivator != null && initialPetFieldState

func after_ready() -> void:
    editorHelper = ForceFieldEditorHelperRes.new(self)

func _process(delta) -> void:
    if editorHelper != null:
        editorHelper.update(delta)
    else:
        # Code to execute in game.
        pass

func activate_player_field() -> void:
    set_color(activeColor)
    playerFieldState = !initialPlayerFieldState
    player_field_toggle(playerFieldState)

func deactivate_player_field() -> void:
    set_color(inactiveColor)
    playerFieldState = initialPlayerFieldState
    player_field_toggle(playerFieldState)

func activate_pet_field() -> void:
    set_color(activeColor)
    petFieldState = !initialPetFieldState
    pet_field_toggle(playerFieldState)

func deactivate_pet_field() -> void:
    set_color(inactiveColor)
    petFieldState = initialPetFieldState
    pet_field_toggle(petFieldState)

func player_field_toggle(_on: bool):
    # TODO animation
    if _on: playerVisualField.show()
    else: playerVisualField.hide()
    playerCollider.process_mode = Node.PROCESS_MODE_INHERIT if _on else Node.PROCESS_MODE_DISABLED

func pet_field_toggle(_on: bool):
    # TODO animation
    if _on: petVisualField.show()
    else: petVisualField.hide()
    petCollider.process_mode = Node.PROCESS_MODE_INHERIT if _on else Node.PROCESS_MODE_DISABLED

func enable_player_field(_enable: bool):
    if _enable:
        verticalPlayerEmitter.show()
        verticalPlayerEmitter.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        verticalPlayerEmitter.hide()
        verticalPlayerEmitter.process_mode = Node.PROCESS_MODE_DISABLED

func enable_pet_field(_enable: bool):
    if _enable:
        horizontalPetEmitter.show()
        horizontalPetEmitter.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        horizontalPetEmitter.hide()
        horizontalPetEmitter.process_mode = Node.PROCESS_MODE_DISABLED

func set_color(newColor: Color) -> void:
    indicatorMesh.get_surface_override_material(0).albedo_color = newColor
    indicatorMesh.get_surface_override_material(0).emission = newColor
