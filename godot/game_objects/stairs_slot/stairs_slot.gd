extends Area3D
class_name StairsSlot

@onready var indicatorMesh: MeshInstance3D = $StairsSlotIndicatorMesh
@onready var gradientMesh: MeshInstance3D = $StairsSlotGradientMesh

signal wire_high
signal wire_low

const DEBOUNCE_SECONDS: float = 0.1

var activatingStairsRef: Stairs = null
var active: bool = false
var cooldownTimer: float = 0.0

var inactiveColor: Color = Color("be8b26")
var activeColor: Color = Color("4b9fce")

func _ready() -> void:
    body_entered.connect(on_body_entered)
    body_exited.connect(on_body_exited)

func _process(delta: float) -> void:
    # debounce because stairs get reparented by platforms which causes multiple redundant signals
    if activatingStairsRef != null && !active:
        if cooldownTimer <= DEBOUNCE_SECONDS:
            cooldownTimer += delta
        else:
            activate()
    elif activatingStairsRef == null && active:
        if cooldownTimer <= DEBOUNCE_SECONDS:
            cooldownTimer += delta
        else:
            deactivate()

func on_body_entered(node: Node) -> void:
    if node is Stairs:
        activatingStairsRef = node

func on_body_exited(node: Node) -> void:
    if node == activatingStairsRef:
        activatingStairsRef = null

@warning_ignore("unused_parameter")
func reset(hard: bool) -> void:
    deactivate()
    for nextNode in get_overlapping_bodies():
        if nextNode is Stairs:
            activatingStairsRef = nextNode

func activate() -> void:
    set_color(activeColor)
    active = true
    cooldownTimer = 0.0
    wire_high.emit()

func deactivate() -> void:
    if active:
        set_color(inactiveColor)
        wire_low.emit()
    active = false
    activatingStairsRef = null
    cooldownTimer = 0.0

func set_color(newColor: Color) -> void:
    indicatorMesh.get_surface_override_material(0).albedo_color = newColor
    indicatorMesh.get_surface_override_material(0).emission = newColor
    gradientMesh.get_surface_override_material(0).set_shader_parameter("Color", newColor)
