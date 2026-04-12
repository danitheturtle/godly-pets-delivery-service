@tool
# plugin dock
const StairsLevelEditorDockRes = preload("res://addons/stairs_level_editor/ui/stairs_level_editor_dock.tscn")

# gizmos
const PlatformCreateAdjacentGizmoRes = preload("res://addons/stairs_level_editor/gizmos/platform_create_adjacent_gizmo.gd")
const StairsCreateAdjacentGizmoRes = preload("res://addons/stairs_level_editor/gizmos/stairs_create_adjacent_gizmo.gd")

# platforms
const SquarePlatformResource = preload("res://game_objects/platform/square_platform.tscn")
enum PLATFORM_TYPE { SQUARE = 0 }
const platformTypeToResourceMap = {
    PLATFORM_TYPE.SQUARE: SquarePlatformResource
}

# puzzle pieces
const StairsResource = preload("res://game_objects/stairs/stairs.tscn")
const StairsSlotResource = preload("res://game_objects/stairs_slot/stairs_slot.tscn")
const StairsSlotAttachedResource = preload("res://game_objects/stairs_slot/stairs_slot_attached.tscn")
enum PUZZLE_PIECE_TYPE { STAIRS = 0, STAIRS_SLOT = 1, STAIRS_SLOT_ATTACHED = 2 }
const puzzlePieceTypeToResourceMap = {
    PUZZLE_PIECE_TYPE.STAIRS: StairsResource,
    PUZZLE_PIECE_TYPE.STAIRS_SLOT: StairsSlotResource,
    PUZZLE_PIECE_TYPE.STAIRS_SLOT_ATTACHED: StairsSlotAttachedResource
}

static func get_default_state():
    return {
        placementMode = "platforms",
        platformType = PLATFORM_TYPE.SQUARE,
        puzzlePieceType = PUZZLE_PIECE_TYPE.STAIRS,
        stairsRise = 11.25,
        stairsRun = 19.5
    }
