@tool
class_name ForceFieldEditorHelper

const EMITTER_HALF_WIDTH = 0.25
const LASER_WIDTH = 0.25

var parent: ForceField
var playerMesh: Node3D = null
var petMesh: Node3D = null
var collisionShape: Shape3D = null

func _init(_parent: ForceField) -> void:
    parent = _parent
    playerMesh = parent.playerVisualField
    petMesh = parent.petVisualField
    collisionShape = parent.playerCollider.get_child(0).shape
    update_field_width(parent.fieldWidth)
    update_field_height(parent.fieldHeight)

func update_field_width(newValue: float) -> void:
    collisionShape.size.x = newValue
    parent.verticalPlayerEmitter.mesh.size.x = newValue
    parent.playerIndicatorMesh.mesh.size.x = newValue
    parent.indicatorMesh.position.x = -newValue/2.0 - 2.0 * EMITTER_HALF_WIDTH
    parent.horizontalPetEmitter.position.x = -newValue / 2.0 - EMITTER_HALF_WIDTH
    parent.petCollider.get_child(0).position.x = newValue / 2.0 + EMITTER_HALF_WIDTH

func update_field_height(newValue: float) -> void:
    collisionShape.size.y = newValue
    parent.horizontalPetEmitter.mesh.size.y = newValue
    parent.petIndicatorMesh.mesh.size.y = newValue
    parent.indicatorMesh.position.y = newValue + 2.0 * EMITTER_HALF_WIDTH
    parent.verticalPlayerEmitter.position.y = newValue + EMITTER_HALF_WIDTH
    parent.horizontalPetEmitter.position.y = newValue / 2.0
    parent.playerCollider.get_child(0).position.y = -newValue / 2.0 - EMITTER_HALF_WIDTH
