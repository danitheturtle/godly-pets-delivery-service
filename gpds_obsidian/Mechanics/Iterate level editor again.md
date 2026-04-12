Full undo, redo, cancel support

Active mesh preview for in-progress actions


Replace platform gizmo with new custom gizmo. Central grabbable gizmo the user drags to target "circles" on a plane aligned with the pivot. When the handle is inside a circle, add mesh at target location. Replaces the 4 handles currently available with more intuitive.
* As the player moves handle between the 4 possible positions, the preview mesh updates in real time

Disable handles where game object already exists. Might require full stair grid, hard to do programmatically unless we have full access to physics at edit time.

New gizmo that highlights possible locations for platforms that can be reached from selected platform in `n` steps or less (n being configurable). Toggle on/off, and toggle between modes:
* Move selected platform to target location
* Create new platform at target location
* Copy location to clipboard so another object can be moved there manually
Can do this by expanding the testing tesselate script I wrote