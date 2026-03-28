@tool
extends Node3D
class_name ForceField

# editor only utils
const ForceFieldEditorHelperRes = preload("res://game_objects/force_field/force_field_editor_helper.gd")
var editorHelper: ForceFieldEditorHelper = null

@onready var verticalPlayerEmitter: MeshInstance3D = $VerticalPlayerEmitter
@onready var playerCollider: StaticBody3D = $VerticalPlayerEmitter/Collider
@onready var playerVisualField: Node3D = $VerticalPlayerEmitter/VisualField
@onready var horizontalPetEmitter: MeshInstance3D = $HorizontalPetEmitter
@onready var petCollider: StaticBody3D = $HorizontalPetEmitter/Collider
@onready var petVisualField: Node3D = $HorizontalPetEmitter/VisualField
@onready var indicatorMesh: MeshInstance3D = $IndicatorMesh
@onready var playerIndicatorMesh: MeshInstance3D = $VerticalPlayerEmitter/PlayerIndicatorMesh
@onready var petIndicatorMesh: MeshInstance3D = $HorizontalPetEmitter/PetIndicatorMesh

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
        if new_value == null: initialPetFieldState = false
        if editorHelper != null: enable_pet_field(new_value != null)
@export var inactiveColor: Color = Color("be8b26") # TODO refactor into color system
@export var activeColor: Color = Color("4b9fce") # TODO refactor into color system
@export_category("Initial State")
@export var initialPlayerFieldState: bool = true:
    set(new_value):
        initialPlayerFieldState = playerFieldActivator != null && new_value
        playerFieldState = initialPlayerFieldState
        if editorHelper != null: player_field_toggle(initialPlayerFieldState)
@export var initialPetFieldState: bool = true:
    set(new_value):
        initialPetFieldState = petFieldActivator != null && new_value
        petFieldState = initialPetFieldState
        if editorHelper != null: pet_field_toggle(initialPetFieldState)
@export_category("Force Field Size")
@export_range(3.0, 30.0, 0.5, "or_greater") var fieldWidth: float = 5.5:
    set(new_value):
        if editorHelper != null: editorHelper.update_field_width(new_value)
        fieldWidth = new_value
@export_range(3.0, 30.0, 0.5, "or_greater") var fieldHeight: float = 5.5:
    set(new_value):
        if editorHelper != null: editorHelper.update_field_height(new_value)
        fieldHeight = new_value

# local state
var playerFieldState: bool = false
var petFieldState: bool = false

func _ready() -> void:
    enable_player_field(playerFieldActivator != null)
    player_field_toggle(initialPlayerFieldState)
    enable_pet_field(petFieldActivator != null)
    pet_field_toggle(initialPetFieldState)
    if Engine.is_editor_hint():
        create_editor_helper.call_deferred()
    else:
        if playerFieldActivator != null:
            playerFieldActivator.wire_high.connect(on_player_wire_high)
            playerFieldActivator.wire_low.connect(on_player_wire_low)
        else:
            verticalPlayerEmitter.free()
        if petFieldActivator != null:
            petFieldActivator.wire_high.connect(on_pet_wire_high)
            petFieldActivator.wire_low.connect(on_pet_wire_low)
        else:
            horizontalPetEmitter.free()
    playerFieldState = playerFieldActivator != null && initialPlayerFieldState
    petFieldState = petFieldActivator != null && initialPetFieldState

func create_editor_helper() -> void:
    editorHelper = ForceFieldEditorHelperRes.new(self)

func on_player_wire_high() -> void: player_field_toggle(!initialPlayerFieldState)

func on_player_wire_low() -> void: player_field_toggle(initialPlayerFieldState)

func on_pet_wire_high() -> void: pet_field_toggle(!initialPetFieldState)

func on_pet_wire_low() -> void: pet_field_toggle(initialPetFieldState)

func player_field_toggle(_on: bool):
    # TODO animation
    playerFieldState = _on
    update_indicator_colors()
    if _on:
        playerVisualField.show()
        playerCollider.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        playerVisualField.hide()
        playerCollider.process_mode = Node.PROCESS_MODE_DISABLED

func pet_field_toggle(_on: bool):
    # TODO animation
    petFieldState = _on
    update_indicator_colors()
    if _on:
        petVisualField.show()
        petCollider.process_mode = Node.PROCESS_MODE_INHERIT
    else:
        petVisualField.hide()
        petCollider.process_mode = Node.PROCESS_MODE_DISABLED

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

func update_indicator_colors() -> void:
    var isPlayerWireHigh = playerFieldState != initialPlayerFieldState
    var isPetWireHigh = petFieldState != initialPetFieldState
    var nextSharedColor = activeColor if isPlayerWireHigh || isPetWireHigh else inactiveColor
    update_mesh_color(nextSharedColor, indicatorMesh)
    if playerFieldActivator != null:
        var nextPlayerColor = activeColor if isPlayerWireHigh else inactiveColor
        update_mesh_color(nextPlayerColor, playerIndicatorMesh)
    if petFieldActivator != null:
        var nextPetColor = activeColor if isPetWireHigh else inactiveColor
        update_mesh_color(nextPetColor, petIndicatorMesh)

func update_mesh_color(newColor: Color, mesh: MeshInstance3D) -> void:
    var surfaceMaterial = mesh.get_surface_override_material(0)
    if surfaceMaterial.albedo_color != newColor:
        surfaceMaterial.albedo_color = newColor
    if surfaceMaterial.emission != newColor:
        surfaceMaterial.emission = newColor
