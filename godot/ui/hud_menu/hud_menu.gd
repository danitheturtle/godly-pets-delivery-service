extends CanvasLayer
class_name HUDMenu

@onready var crosshair = $MarginContainer/GridContainer/CenterContainer/Crosshair
@onready var popup = $MarginContainer/GridContainer/BottomContainer/PopupPanel

var currentInnerPopup = null

func _ready() -> void:
    SignalBus.popup_displayed.connect(on_popup_displayed)
    SignalBus.popup_closed.connect(on_popup_closed)

func on_popup_displayed(innerPopupTree: Control) -> void:
    currentInnerPopup = innerPopupTree
    popup.show()
    popup.add_child(innerPopupTree)
    innerPopupTree.owner = get_tree().root

func on_popup_closed() -> void:
    popup.hide()
    if currentInnerPopup != null:
        popup.remove_child(currentInnerPopup)
        currentInnerPopup = null
