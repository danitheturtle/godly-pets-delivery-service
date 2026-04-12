(done) Switch between platform and "puzzle piece" placement with hotkey. stairs are selectable as a type of "puzzle piece"

(wip) Select type of platform/puzzle piece to place next from sidebar dock
 - ui done, needs placement code
 
(wip) add handle to ends of staircases to add another puzzle piece or platform. reuse the existing toggle

Stretch:
Instead of handles, use mesh representations for things

Disable handles where platforms / stairs already exist (this means we gotta run the stair graph at editor time? not sure its possible)

New gizmo that highlights possible locations for platforms that can be reached from selected platform in `n` steps or less (n being configurable). Toggle on/off, and toggle between 2 modes:
* Move selected platform to target location
* Create new platform at target location
Can do this by expanding the testing tesselate script I wrote
