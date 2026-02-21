@tool
extends VFlowContainer

@onready var gridOriginX = $GridOriginVector/GridOriginX
@onready var gridOriginY = $GridOriginVector/GridOriginY
@onready var gridOriginZ = $GridOriginVector/GridOriginZ
@onready var platformSideLengthInput = $PlatformSideLength
@onready var platformSideCountInput = $PlatformSideCount

func _ready() -> void:
	gridOriginX.changed.connect(_grid_origin_x_changed)
	gridOriginY.changed.connect(_grid_origin_y_changed)
	gridOriginZ.changed.connect(_grid_origin_z_changed)
	platformSideLengthInput.changed.connect(_platform_side_length_changed)
	platformSideCountInput.changed.connect(_platform_side_count_changed)

func _grid_origin_x_changed(nextX: float):
	SnapState.gridOrigin.x = nextX
	
func _grid_origin_y_changed(nextY: float):
	SnapState.gridOrigin.y = nextY

func _grid_origin_z_changed(nextZ: float):
	SnapState.gridOrigin.z = nextZ

func _platform_side_length_changed(nextLength: float):
	SnapState.platformSideLength = nextLength

func _platform_side_count_changed(nextCount: int):
	SnapState.platformSideCount = nextCount
