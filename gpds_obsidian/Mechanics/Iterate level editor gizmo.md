Switch between stair and platform placement with hotkey

add handle to ends of staircases to add another staircase or platform. reuse the existing toggle

Selecting type of platform/stair to place next from sidebar dock

Disable handles where platforms / stairs already exist (this means we gotta run the stair graph at editor time? not sure its possible)

New gizmo that highlights possible locations for platforms that can be reached from selected platform in `n` steps or less (n being configurable). Toggle on/off, and toggle between 2 modes:
* Move selected platform to target location
* Create new platform at target location
Can do this by expanding the testing tesselate script I wrote

Instead of handles, use mesh representations for things
