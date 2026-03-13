Every level object is a navmesh region for static geometry that gets baked based on collision layer 3

Every sub-level has its own navmesh region that dynamically populates at runtime to cover the level pieces.
* When a part of the level moves, the navmesh for the sublevel gets updated.
* Try to do it performantly but re-building the whole thing isn't the end of the world.

Region adjacency should be set globally to a very forgiving value.

Potentially possible to give each platform its own nav region and static navmesh so it doesn't have to be re-built every time. The docs say NavRegion's transform can be modified so maybe just have it be a child of the platform and let existing rotation handle it.

Stair navmeshes are actually static to the platform and just appear/disappear based on stair state. Have to keep track of actual stairs somehow instead of just pivot orientation. Try to do it without full stair graph