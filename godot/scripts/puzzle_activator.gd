@abstract
class_name PuzzleActivator
extends Area3D

signal wire_high
signal wire_low

var inactiveColor: Color = Color("be8b26") # TODO refactor into color system
var activeColor: Color = Color("4b9fce") # TODO refactor into color system

const DEBOUNCE_SECONDS: float = 0.065

var activatingNodeRef: CollisionObject3D = null
var active: bool = false
var cooldownTimer: float = 0.0

func _ready() -> void:
    body_entered.connect(on_body_entered)
    body_exited.connect(on_body_exited)

func _process(delta: float) -> void:
    # debounce because stairs get reparented by platforms which causes multiple redundant signals
    if activatingNodeRef != null && !active:
        if cooldownTimer <= DEBOUNCE_SECONDS:
            cooldownTimer += delta
        else:
            activate()
    elif activatingNodeRef == null && active:
        if cooldownTimer <= DEBOUNCE_SECONDS:
            cooldownTimer += delta
        else:
            deactivate()

func activate() -> void:
    if !active:
        wire_high.emit()
        set_color(activeColor)
        active = true
    cooldownTimer = 0.0

func deactivate() -> void:
    if active:
        set_color(inactiveColor)
        wire_low.emit()
        active = false
        activatingNodeRef = null
    cooldownTimer = 0.0

@abstract func reset(hard: bool) -> void

@abstract func set_color(newColor: Color) -> void

@abstract func on_body_entered(node: Node) -> void

@abstract func on_body_exited(node: Node) -> void
