class_name PlatformNavmesh

var _world3D: RID
var _region: RID
var _parent: Platform
func _init(world3D: RID, parent: Platform):
    _parent = parent
    _world3D = world3D
    setup_navigation.call_deferred()

func setup_navigation():
    _region = NavigationServer3D.region_create()
    NavigationServer3D.region_set_transform(_region, _parent.transform)
    NavigationServer3D.region_set_map(_region, _world3D)
