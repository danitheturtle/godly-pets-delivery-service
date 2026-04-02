@tool
class_name LaserFieldEditorHelper

const EMITTER_HALF_WIDTH = 0.25
const LASER_WIDTH = 0.25
const LASER_GAP = LASER_WIDTH * 3

var parent: LaserField
var collisionShape: Shape3D = null

var verticalPlayerLasers: Array[MeshInstance3D] = []
var horizontalPetLasers: Array[MeshInstance3D] = []

func _init(_parent: LaserField) -> void:
    parent = _parent
    collisionShape = parent.playerCollider.get_child(0).shape
    for nextChild in parent.playerVisualField.get_children():
        if nextChild is MeshInstance3D:
            verticalPlayerLasers.append(nextChild)
    for nextChild in parent.petVisualField.get_children():
        if nextChild is MeshInstance3D:
            horizontalPetLasers.append(nextChild)
    update_field_width(parent.fieldWidth)
    update_field_height(parent.fieldHeight)

func update_field_width(newWidth: float) -> void:
    var halfNew = newWidth / 2.0
    collisionShape.size.x = newWidth
    parent.verticalPlayerEmitter.mesh.size.x = newWidth
    parent.playerIndicatorMesh.mesh.size.x = newWidth
    parent.indicatorMesh.position.x = -halfNew - 2.0 * EMITTER_HALF_WIDTH
    parent.horizontalPetEmitter.position.x = -halfNew - EMITTER_HALF_WIDTH
    parent.petCollider.get_child(0).position.x = halfNew + EMITTER_HALF_WIDTH
    horizontalPetLasers[0].mesh.height = newWidth
    for nextChild in horizontalPetLasers:
        if nextChild == null: continue
        nextChild.position.x = halfNew + EMITTER_HALF_WIDTH
    update_vertical_lasers(halfNew)

func update_field_height(newHeight: float) -> void:
    var halfNew = newHeight / 2.0
    collisionShape.size.y = newHeight
    parent.horizontalPetEmitter.mesh.size.y = newHeight
    parent.petIndicatorMesh.mesh.size.y = newHeight
    parent.indicatorMesh.position.y = newHeight + 2.0 * EMITTER_HALF_WIDTH
    parent.verticalPlayerEmitter.position.y = newHeight + EMITTER_HALF_WIDTH
    parent.horizontalPetEmitter.position.y = halfNew
    parent.playerCollider.get_child(0).position.y = -halfNew - EMITTER_HALF_WIDTH
    verticalPlayerLasers[0].mesh.height = newHeight
    for nextChild in verticalPlayerLasers:
        if nextChild == null: continue
        nextChild.position.y = -halfNew - EMITTER_HALF_WIDTH
    update_horizontal_lasers(halfNew)

func update_vertical_lasers(halfWidth: float) -> void:
    var startPositionX = -halfWidth - EMITTER_HALF_WIDTH
    var maxArrayPos = startPositionX
    for i in range(verticalPlayerLasers.size()):
        maxArrayPos = startPositionX + (i+1)*(LASER_GAP + LASER_WIDTH)
        if maxArrayPos <= halfWidth:
            if verticalPlayerLasers[i] == null:
                verticalPlayerLasers[i] = dupe_zeroth_laser(verticalPlayerLasers, parent.playerVisualField)
            verticalPlayerLasers[i].position.x = maxArrayPos
        elif verticalPlayerLasers[i] != null:
                verticalPlayerLasers[i].free()
                verticalPlayerLasers[i] = null
    while maxArrayPos < halfWidth - LASER_GAP:
        var newLaser = dupe_zeroth_laser(verticalPlayerLasers, parent.playerVisualField)
        maxArrayPos = startPositionX + verticalPlayerLasers.size()*(LASER_GAP + LASER_WIDTH)
        newLaser.position.x = maxArrayPos
        verticalPlayerLasers.append(newLaser)

func update_horizontal_lasers(halfHeight: float) -> void:
    var startPositionY = halfHeight + EMITTER_HALF_WIDTH
    var maxArrayPos = startPositionY
    for i in range(horizontalPetLasers.size()):
        # skip first laser as it would be inside emitter
        maxArrayPos = startPositionY - (i+1)*(LASER_GAP + LASER_WIDTH)
        if maxArrayPos >= -halfHeight:
            if horizontalPetLasers[i] == null:
                horizontalPetLasers[i] = dupe_zeroth_laser(horizontalPetLasers, parent.petVisualField)
            horizontalPetLasers[i].position.y = maxArrayPos
        elif horizontalPetLasers[i] != null:
                horizontalPetLasers[i].free()
                horizontalPetLasers[i] = null
    while maxArrayPos > -halfHeight + LASER_GAP:
        var newLaser = dupe_zeroth_laser(horizontalPetLasers, parent.petVisualField)
        maxArrayPos = startPositionY - horizontalPetLasers.size()*(LASER_GAP + LASER_WIDTH)
        newLaser.position.y = maxArrayPos
        horizontalPetLasers.append(newLaser)

func dupe_zeroth_laser(lasers: Array[MeshInstance3D], newLaserParent: Node) -> MeshInstance3D:
    var newLaser = lasers[0].duplicate()
    newLaserParent.add_child(newLaser)
    newLaser.owner = EditorInterface.get_edited_scene_root()
    return newLaser
