First player input of rotation/pivot command:
* Store `startIndex`.
* Reset `currentPos` and `queuedRotations` / `queuedPivots` to 0, then increment/decrement `queuedRotations` / `queuedPivots` based on input direction.
* Set `rotating` or `pivoting` to true.

Every input:
* Count key presses using `queuedRotations` / `queuedPivots`, with overall sign representing direction.
	* Increment / decrement based on direction
	* Cap value at rotation/pivot stop count (one full rotation)
* Wrap `startIndex` + `queuedRotations` to get `targetIndex` immediately on every input, to be reflected in the UI

Every loop:
* If rotating or pivoting and `currentPos` != `targetPos`, rotate to target in the correct direction with angular velocity scaled to keep the `ROTATION_TIME` constant no matter how far objects travel or how player input might change it
* Store the `currentPos` in the rotation in degrees from -180 to 180.
* At increments of 360/stops, clamp basis to stored basis to avoid float errors
* If object would rotate through one of its stops, set the `currentIndex`
* if `currentPos` == `targetPos`, set `rotating` or `pivoting` to false

UI:
* 2d plane above every pivot and on floor of platform that acts as a circular progress bar.
* One line indicates `currentPos`, and another indicates `targetPos`.
* Rotation starts with a filled bar arcing between them in the direction of the sign of `queued*`.
* This UI updates immediately as the player inputs, showing them exactly where the platform or stairs will end up.
* As `currentPos` changes, the progress bar shrinks towards `targetPos`
* Should be relative to stair's rotation position, since pivots rotation doesn't line up 1-1. could be as simple as copying stair's global_rotation.y to the 2d rotation of the canvas item

Notes:
* Collision returns object to the `currentIndex`, not the `startIndex`
* Manually wrap between -180 and 180 since quaternions are a fuck and we can just avoid them with indexed bases