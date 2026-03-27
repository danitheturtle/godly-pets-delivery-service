class_name FloorButton
extends PuzzleActivator

@onready var indicatorMesh: MeshInstance3D = $FloorButtonIndicatorMesh

func on_body_entered(node: Node) -> void:
    if node is Player or node is Pet:
        activatingNodeRef = node

func on_body_exited(node: Node) -> void:
    if !(node is Player or node is Pet):
        return
    var collidingBodies = []
    for nextNode in get_overlapping_bodies():
        if nextNode is Player or nextNode is Pet:
            collidingBodies.append(nextNode)
    if collidingBodies.size() == 0:
        activatingNodeRef = null

@warning_ignore("unused_parameter")
func reset(hard: bool) -> void:
    deactivate()
    for nextNode in get_overlapping_bodies():
        if nextNode is Player or nextNode is Pet:
            activatingNodeRef = nextNode

func activate() -> void:
    super.activate()
    indicatorMesh.transform.origin.y = -0.035
    # TODO: button animation

func deactivate() -> void:
    super.deactivate()
    indicatorMesh.transform.origin.y = 0.145
    # TODO: button animation

func set_color(newColor: Color) -> void:
    indicatorMesh.get_surface_override_material(0).albedo_color = newColor
    indicatorMesh.get_surface_override_material(0).emission = newColor
