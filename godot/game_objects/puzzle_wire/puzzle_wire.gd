extends Node
class_name PuzzleWire
# implements PuzzleActivator, sort of

@export_enum("AND", "OR") var mode = "AND"
# activator group nodes emit wire_high and wire_low
@export var activators: Array[Node]

signal wire_high
signal wire_low

var activatorsState: Array[bool] = []
var active: bool = false

func _ready() -> void:
    if activators.size() > 0:
        for i in range(0,activators.size()):
            activators[i].wire_high.connect(on_wire_high(i))
            activators[i].wire_low.connect(on_wire_low(i))
            activatorsState.append(false)

func calculate() -> void:
    if !active:
        var testResult = areAllTrue() if mode == "AND" else isOneTrue()
        if testResult:
            wire_high.emit()
            active = true
    else:
        var testResult = areAllTrue() if mode == "AND" else isOneTrue()
        if !testResult:
            wire_low.emit()
            active = false

func areAllTrue() -> bool:
    var allTrue = true
    for nextState in activatorsState:
        allTrue = allTrue && nextState
    return allTrue

func isOneTrue() -> bool:
    var oneTrue = false
    for nextState in activatorsState:
        oneTrue = oneTrue || nextState
    return oneTrue

func on_wire_high(index: int):
    return func ():
        activatorsState[index] = true
        calculate()

func on_wire_low(index: int):
    return func ():
        activatorsState[index] = false
        calculate()
