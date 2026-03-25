Basically a stair can be a key. Maybe even a specific stair has to go to a specific slot. Putting a stair in its slot and leaving it can activate a wire

Stair slot is a square hole placed at target pivot. It's placed instead of a platform (or maybe attached to a platform)

In this configuration, a stair can fit the slot in 4 different orientations. A few options:
* Use 2 slots for fixed orientation solutions
* Only put slot in a place reachable in one way
* give directionality to slots

Square slot with glowing emitter (static mesh with gradient). Could be angled to show direction slot works in, or just left static. Once the slot is active, the emitter disappears and the slot turns green or some other visual active state.

Iterate mesh:
* "attached to platform" version that sticks onto surface and underside of platform. needed so slot is visible from a distance
* Thicken radial indicator so its squared off with gradient emitter
