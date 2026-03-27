class_name StairsSlot
extends PuzzleActivator

@onready var indicatorMesh: MeshInstance3D = $StairsSlotIndicatorMesh
@onready var gradientMesh: MeshInstance3D = $StairsSlotGradientMesh

func on_body_entered(node: Node) -> void:
    if node is Stairs:
        activatingNodeRef = node

func on_body_exited(node: Node) -> void:
    if node == activatingNodeRef:
        activatingNodeRef = null

@warning_ignore("unused_parameter")
func reset(hard: bool) -> void:
    deactivate()
    for nextNode in get_overlapping_bodies():
        if nextNode is Stairs:
            activatingNodeRef = nextNode

func set_color(newColor: Color) -> void:
    indicatorMesh.get_surface_override_material(0).albedo_color = newColor
    indicatorMesh.get_surface_override_material(0).emission = newColor
    gradientMesh.get_surface_override_material(0).set_shader_parameter("Color", newColor)
