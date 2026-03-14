extends AnimatableBody3D
class_name Stairs

@export var stairWidth: float = 3.0
@export var stairRise: float = 11.25
@export var stairRun: float = 19.5
@export var navAgentRadius: float = 0.75
@export var navCellHeight: float = 0.25

@onready var initialParent = get_parent()
@onready var initialTransform = Transform3D(transform)
@onready var collisionArea = $CenterCollisionArea3D
@onready var secondaryCollisionArea = $EndsArea3D
@onready var navRegionsBySide: Dictionary[float, NavigationRegion3D] = {
    0.0: $TopNavigationRegion3D,
    -90.0: $RightNavigationRegion3D,
    180.0: $BottomNavigationRegion3D,
    90.0: $LeftNavigationRegion3D
}

# if needed, can use colliders to derive stair orientation
#@onready var topCollider = $Area3D/TopSphereShape3D
#@onready var bottomCollider = $Area3D/BottomSphereShape3D
# example:
# var pivotedFromBottom = topCollider.global_transform.origin.y > bottomCollider.global_transform.origin.y

var attachedToPlatform: Platform = null
var storedParent: Node3D
var storedTransform: Transform3D

var pivoting: bool = false

func _ready() -> void:
    storedParent = initialParent
    storedTransform = initialTransform
    # listen for checkpoints
    SignalBus.checkpoint_activated.connect(on_checkpoint_reached)
    build_nav_regions()
    detect_and_enable_floor_navregion()

func reset(hard: bool = false) -> void:
    if (!hard):
        reparent(storedParent, false)
        transform = storedTransform
    else:
        reparent(initialParent, false)
        transform = initialTransform

func attach_to_platform(platform: Platform) -> void:
    if platform != attachedToPlatform:
        if attachedToPlatform != null:
            if attachedToPlatform.is_connected("stairs_pivot_started", on_stairs_pivot_started):
                attachedToPlatform.stairs_pivot_started.disconnect(on_stairs_pivot_started)
            if attachedToPlatform.is_connected("stairs_pivot_finished", on_stairs_pivot_finished):
                attachedToPlatform.stairs_pivot_finished.disconnect(on_stairs_pivot_finished)
        platform.stairs_pivot_started.connect(on_stairs_pivot_started)
        platform.stairs_pivot_finished.connect(on_stairs_pivot_finished)
        attachedToPlatform = platform

func build_nav_regions() -> void:
    for deg in range(-90, 181, 90):
        var newRegion = navRegionsBySide[deg]
        var regionNavMesh: NavigationMesh = newRegion.navigation_mesh
        regionNavMesh.clear()
        var vertices: PackedVector3Array
        # build vert array and tris based on stair position, in clockwise order
        match deg:
            0: vertices = get_top_nav_verts()
            -90: vertices = get_right_nav_verts()
            180: vertices = get_bottom_nav_verts()
            90: vertices = get_left_nav_verts()
        regionNavMesh.set_vertices(vertices)
        regionNavMesh.add_polygon(PackedInt32Array([0, 1, 2]))
        regionNavMesh.add_polygon(PackedInt32Array([2, 1, 3]))
        # set transform but only the basis
        update_nav_region_transform(newRegion)
        #set_nav_region_enabled(newRegionRID, false)

func update_nav_region_transform(region):
    region.transform.origin = global_transform.origin
    region.transform.basis = Basis.IDENTITY.rotated(Vector3.UP, global_rotation.y)

# enable the navregion representing the floor at current rotation
func detect_and_enable_floor_navregion():
    # determine which region to enable
    var roundedZRotation = round(global_rotation_degrees.z)
    # both -180 and 180 represent the same nav region to activate
    if roundedZRotation == -180.0:
        roundedZRotation = 180.0
    # enable the correct nav region
    navRegionsBySide[roundedZRotation].enabled = true

func get_top_nav_verts() -> PackedVector3Array:
    var closeYValue = -stairRise/2 + stairWidth/2 + navCellHeight
    var farYValue = stairRise/2 + stairWidth/2 + navCellHeight
    return get_vertical_nav_verts(closeYValue, farYValue)

func get_right_nav_verts() -> PackedVector3Array:
    var xValue = -stairWidth/2 - navCellHeight
    return get_horizontal_nav_verts(xValue)

func get_bottom_nav_verts() -> PackedVector3Array:
    var closeYValue = stairRise/2 + stairWidth/2 + navCellHeight
    var farYValue = -stairRise/2 + stairWidth/2 + navCellHeight
    return get_vertical_nav_verts(closeYValue, farYValue)

func get_vertical_nav_verts(closeYValue: float, farYValue: float) -> PackedVector3Array:
    var xValue = stairWidth/2 - navAgentRadius
    var zValue = stairRun/2
    return PackedVector3Array([
        Vector3(xValue, closeYValue, zValue),
        Vector3(xValue, farYValue, -zValue),
        Vector3(-xValue, closeYValue, zValue),
        Vector3(-xValue, farYValue, -zValue)
    ])

func get_left_nav_verts() -> PackedVector3Array:
    var xValue = stairWidth/2 + navCellHeight
    return get_horizontal_nav_verts(xValue)

func get_horizontal_nav_verts(xValue: float):
    var zValue = stairRun/2
    return PackedVector3Array([
        Vector3(xValue, -stairRise/2 + stairWidth/2 - navAgentRadius, zValue),
        Vector3(xValue, stairRise/2 + stairWidth/2 - navAgentRadius, -zValue),
        Vector3(xValue, -stairRise/2 - stairWidth/2 + navAgentRadius, -zValue),
        Vector3(xValue, stairRise/2 - stairWidth/2 + navAgentRadius, zValue),
    ])

func on_checkpoint_reached() -> void:
    storedParent = get_parent()
    storedTransform = Transform3D(transform)

func on_stairs_pivot_started():
    pivoting = true
    for nextNavKey in navRegionsBySide.keys():
        navRegionsBySide[nextNavKey].enabled = false

@warning_ignore("unused_parameter")
func on_stairs_pivot_finished(cancelled: bool):
    pivoting = false
    # update transforms to new position
    for nextNavKey in navRegionsBySide.keys():
        update_nav_region_transform(navRegionsBySide[nextNavKey])
    detect_and_enable_floor_navregion()
