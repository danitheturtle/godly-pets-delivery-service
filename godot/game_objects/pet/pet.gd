extends CharacterBody3D
class_name Pet

@export var PET_INERTIA: float = 1.0
@export var FOLLOW_DISTANCE: float = 2.0
@export var VELOCITY_EXTRA_DAMP: float = 2.0
@export var EXTRA_DAMP_ABOVE_SPEED_SQ: float = 3.0
var SQUARED_FOLLOW_DISTANCE = FOLLOW_DISTANCE * FOLLOW_DISTANCE
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
var GRAVITY_VECTOR = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var LINEAR_DAMP = ProjectSettings.get_setting("physics/3d/default_linear_damp")

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

var followingPlayer: bool = false

func _ready() -> void:
    State.pet = self

func _physics_process(_delta: float) -> void:
    var vectorToPlayer = global_position - State.player.global_position
    # if distance to player is less than follow distance, do nothing
    if vectorToPlayer.length_squared() > SQUARED_FOLLOW_DISTANCE:
        pass
        # TODO
    
    # apply gravity
    velocity += GRAVITY*_delta * GRAVITY_VECTOR
    # apply gamefeel-scaled linear damping on xz plane
    var dampingVector = -Vector3(velocity.x, 0.0, velocity.z) * VELOCITY_EXTRA_DAMP
    # lessen damping effect above speed, but also give it a floor of 1.0
    if velocity.length_squared() < EXTRA_DAMP_ABOVE_SPEED_SQ:
        dampingVector = dampingVector.normalized()
    velocity += dampingVector * LINEAR_DAMP * _delta
    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    var eventHandled: bool = false
    if (event.is_action_released("pet_action")):
        on_pet_action()
        eventHandled = true
    if (eventHandled):
        get_tree().root.set_input_as_handled()

func on_pet_action() -> void:
    followingPlayer = !followingPlayer
