A custom gizmo for placing platforms and stairs.

A selected platform with this gizmo enabled will have 4 gizmo spheres at each stair pivot with a global toggle between 2 modes: stair placement and platform placement. 

When clicked, the gizmo spawns a new platform or staircase in the position represented by the clicked gizmo. Later functionality can include selecting type of platform/stair to place next.
* as a stretch, disable buttons where platforms already exist

The advantage to doing this is programmatically setting the position of new pieces without having to calculate them by hand each time.

Possible positions are highlighted based on the puzzle grid.