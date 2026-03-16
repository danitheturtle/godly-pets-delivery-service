extends CharacterBody3D
class_name Pet

@export var PET_SPEED: float = 12.0
@export var PET_INERTIA: float = 1.0
@export var FOLLOW_DISTANCE: float = 2.5
@export var ARRIVE_DISTANCE: float = 16.0
@export var REGEN_PATH_DISTANCE: float = 3.0
@export var EXTRA_LINEAR_DAMP: float = 1.25
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
var GRAVITY_VECTOR = ProjectSettings.get_setting("physics/3d/default_gravity_vector")
var LINEAR_DAMP = ProjectSettings.get_setting("physics/3d/default_linear_damp") + EXTRA_LINEAR_DAMP

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D

var followingPlayer: bool = false

func _ready() -> void:
    State.pet = self

func _physics_process(_delta: float) -> void:
    if NavigationServer3D.map_get_iteration_id(navAgent.get_navigation_map()) == 0:
        return
    var toPlayer = State.player.global_position - global_position
    var toPlayerLength = toPlayer.length()
    var velocityYComponent = Vector3(0,velocity.y,0)
    # if not following player or distance to player is less than follow distance, do nothing
    if followingPlayer && toPlayerLength > FOLLOW_DISTANCE:
        var playerToTarget = navAgent.target_position - State.player.global_position
        if !navAgent.is_navigation_finished() && playerToTarget.length_squared() <= REGEN_PATH_DISTANCE * REGEN_PATH_DISTANCE:
            var nextPosition = navAgent.get_next_path_position()
            velocity = velocityYComponent + Vector3(global_position.x, 0, global_position.z).direction_to(Vector3(nextPosition.x, 0, nextPosition.z)) * PET_SPEED
        else:
            navAgent.target_position = State.player.global_position
        # arrive at player with a damping vectorfaw
        if toPlayerLength < ARRIVE_DISTANCE:
            velocity = velocityYComponent + Vector3(velocity.x, 0, velocity.z) * toPlayerLength / ARRIVE_DISTANCE
    else:
        # apply damping force proportional to velocity
        var dampingVector = -Vector3(velocity.x, 0, velocity.z) * LINEAR_DAMP
        velocity += dampingVector * _delta
    # apply gravity
    velocity += GRAVITY*_delta * GRAVITY_VECTOR
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
