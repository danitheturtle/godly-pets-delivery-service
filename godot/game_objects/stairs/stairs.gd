extends AnimatableBody3D
class_name Stairs

@export var stairWidth: float = 3.0
@export var stairRise: float = 11.25
@export var stairRun: float = 19.5
@export var navAgentRadius: float = 0.75
@export var navCellHeight: float = 0.5

@onready var initialParent = get_parent()
@onready var initialTransform = Transform3D(transform)
@onready var collisionArea = $CenterCollisionArea3D
@onready var secondaryCollisionArea = $EndsArea3D
# if needed, can use colliders to derive stair orientation
#@onready var topCollider = $Area3D/TopSphereShape3D
#@onready var bottomCollider = $Area3D/BottomSphereShape3D
@onready var navRegionsBySide: Dictionary[float, NavigationRegion3D] = {
    0.0: $Navigation/TopRegion,
    -90.0: $Navigation/RightRegion,
    180.0: $Navigation/BottomRegion,
    90.0: $Navigation/LeftRegion
}

var attachedToPlatform: Platform = null
var storedParent: Node3D
var storedTransform: Transform3D

func _enter_tree() -> void:
    # nav regions have relative transforms until runtime to prevent weird object bounding box issues
    for nextNavRegion in find_child("Navigation").get_children():
        nextNavRegion.top_level = true

func _ready() -> void:
    storedParent = initialParent
    storedTransform = initialTransform
    # listen for checkpoints
    SignalBus.checkpoint_activated.connect(on_checkpoint_reached)
    nav_build_meshes_and_init.call_deferred()

func reset(hard: bool = false) -> void:
    if (!hard):
        reparent(storedParent, false)
        transform = storedTransform
    else:
        reparent(initialParent, false)
        transform = initialTransform
    nav_apply_transform_to_regions()
    nav_detect_and_enable_only_floor.call_deferred()

func attach_to_platform(platform: Platform) -> void:
    if platform != attachedToPlatform:
        if attachedToPlatform != null:
            if attachedToPlatform.is_connected("stairs_pivot_started", on_pivot_started):
                attachedToPlatform.stairs_pivot_started.disconnect(on_pivot_started)
            if attachedToPlatform.is_connected("platform_rotation_started", on_pivot_started):
                attachedToPlatform.platform_rotation_started.disconnect(on_pivot_started)
            if attachedToPlatform.is_connected("stairs_pivot_finished", on_pivot_finished):
                attachedToPlatform.stairs_pivot_finished.disconnect(on_pivot_finished)
            if attachedToPlatform.is_connected("platform_rotation_finished", on_pivot_started):
                attachedToPlatform.platform_rotation_finished.disconnect(on_pivot_started)
        if !platform.is_connected("stairs_pivot_started", on_pivot_started):
            platform.stairs_pivot_started.connect(on_pivot_started)
        if !platform.is_connected("platform_rotation_started", on_pivot_started):
            platform.platform_rotation_started.connect(on_pivot_started)
        if !platform.is_connected("stairs_pivot_finished", on_pivot_finished):
            platform.stairs_pivot_finished.connect(on_pivot_finished)
        if !platform.is_connected("platform_rotation_finished", on_pivot_finished):
            platform.platform_rotation_finished.connect(on_pivot_finished)
        attachedToPlatform = platform

func on_checkpoint_reached() -> void:
    storedParent = get_parent()
    storedTransform = Transform3D(transform)

func on_pivot_started():
    nav_disable_regions()

@warning_ignore("unused_parameter")
func on_pivot_finished(cancelled: bool):
    nav_apply_transform_to_regions()
    nav_detect_and_enable_only_floor.call_deferred()

# 
#  NAVMESH STUFF
#
func nav_build_meshes_and_init() -> void:
    await get_tree().physics_frame
    nav_apply_transform_to_regions()
    await get_tree().physics_frame
    for deg in range(-90, 181, 90):
        var newRegion = navRegionsBySide[deg]
        var regionNavMesh: NavigationMesh = newRegion.navigation_mesh
        regionNavMesh.clear()
        var vertices: PackedVector3Array
        # build vert array and tris based on stair position, in clockwise order
        match deg:
            0: vertices = nav_get_top_verts()
            -90: vertices = nav_get_right_verts()
            180: vertices = nav_get_bottom_verts()
            90: vertices = nav_get_left_verts()
        regionNavMesh.set_vertices(vertices)
        regionNavMesh.add_polygon(PackedInt32Array([0, 1, 2]))
        regionNavMesh.add_polygon(PackedInt32Array([2, 1, 3]))
    nav_detect_and_enable_only_floor()

func nav_apply_transform_to_regions() -> void:
    var newGlobalTransform = Transform3D(Basis.IDENTITY.rotated(Vector3.UP, global_rotation.y), global_transform.origin)
    for deg in navRegionsBySide.keys():
        navRegionsBySide[deg].global_transform = newGlobalTransform

# enable the navregion representing the floor at current rotation
func nav_detect_and_enable_only_floor():
    await get_tree().physics_frame
    nav_disable_regions()
    # determine which region to enable
    var roundedZRotation = snappedf(global_rotation_degrees.z, 90.0)
    # both -180 and 180 represent the same nav region to activate
    if roundedZRotation == -180.0:
        roundedZRotation = 180.0
    # enable the correct nav region
    navRegionsBySide[roundedZRotation].enabled = true

func nav_get_top_verts() -> PackedVector3Array:
    var closeYValue = -stairRise/2 + stairWidth/2 + navCellHeight
    var farYValue = stairRise/2 + stairWidth/2 + navCellHeight
    return nav_get_vertical_verts(closeYValue, farYValue)

func nav_get_right_verts() -> PackedVector3Array:
    return nav_get_horizontal_verts(true)

func nav_get_bottom_verts() -> PackedVector3Array:
    var closeYValue = stairRise/2 + stairWidth/2 + navCellHeight
    var farYValue = -stairRise/2 + stairWidth/2 + navCellHeight
    return nav_get_vertical_verts(closeYValue, farYValue)

func nav_get_left_verts() -> PackedVector3Array:
    return nav_get_horizontal_verts(false)

func nav_get_vertical_verts(closeYValue: float, farYValue: float) -> PackedVector3Array:
    var xValue = stairWidth/2 - navAgentRadius
    var zValue = stairRun/2
    return PackedVector3Array([
        Vector3(xValue, closeYValue, zValue),
        Vector3(xValue, farYValue, -zValue),
        Vector3(-xValue, closeYValue, zValue),
        Vector3(-xValue, farYValue, -zValue)
    ])

func nav_get_horizontal_verts(isRight: bool):
    var nearXValue = stairRise/2 - stairWidth/2 + navAgentRadius
    var farXValue = stairRise/2 + stairWidth/2 - navAgentRadius
    if isRight:
        nearXValue *= -1
        farXValue *= -1
    var yValue = stairWidth / 2 + navCellHeight
    var zValue = stairRun/2
    return PackedVector3Array([
        Vector3(farXValue, yValue, zValue),
        Vector3(-nearXValue, yValue, -zValue),
        Vector3(nearXValue, yValue, zValue),
        Vector3(-farXValue, yValue, -zValue),
    ])

func nav_disable_regions() -> void:
    for nextNavKey in navRegionsBySide.keys():
        if navRegionsBySide[nextNavKey].enabled:
            navRegionsBySide[nextNavKey].enabled = false
