@tool
class_name ForceFieldEditorHelper

var parent: ForceField
#shortcut vars
var playerEmitter: MeshInstance3D = null
var playerCol: StaticBody3D = null
var playerMesh: Node3D = null
var petEmitter: MeshInstance3D = null
var petCol: StaticBody3D = null
var petMesh: Node3D = null

func _init(_parent: ForceField) -> void:
    parent = _parent
    playerEmitter = parent.verticalPlayerEmitter
    playerCol = parent.playerCollider
    playerMesh = parent.playerVisualField
    petEmitter = parent.horizontalPetEmitter
    petCol = parent.petCollider
    petMesh = parent.petVisualField

func update(delta: float) -> void:
    pass
