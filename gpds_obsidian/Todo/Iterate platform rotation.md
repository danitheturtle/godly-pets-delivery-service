First player input of rotation/pivot command:
* Set `active` to true.
* Store `currentIndex` as `startIndex` and calculate `startPosRad`
* Reset `timer`, `distFromStartRad`, `currentPosRad` and `queued` to 0

Every input:
* Count key presses using `queued`, with overall sign representing direction.
	* Increment / decrement based on direction
	* Cap value at rotation/pivot stop count (one full rotation)
* Wrap `startIndex` + `queued` to get `targetIndex` immediately on every input, to be reflected in the UI
* get `distToTargetRad` from `queued` * `radPerStop`

Every loop:
* Get position in animation from 0.0 to 1.0 based on `timer` and `timerLength` and anim function
* If `active` and `distFromStartRad` != `distToTargetRad`, get magnitude and direction of difference
	* mag =||target - current||
	* dir = +1 if target > current else -1
* remap anim position into range 0-`rotationDiff` to get next step of rotation
* If object would rotate through one of its stops, set the `currentIndex`
* when times up or if currentRotationRad + nextStep > targetRotationRad, set `active` to false and exit early

UI:
* 2d plane above every pivot and on floor of platform that acts as a circular progress bar.
* One line indicates `currentPos`, and another indicates `targetPos`.
* Rotation starts with a filled bar arcing between them in the direction of the sign of `queued*`.
* This UI updates immediately as the player inputs, showing them exactly where the platform or stairs will end up.
* As `currentPos` changes, the progress bar shrinks towards `targetPos`
* Should be relative to stair's rotation position, since pivots rotation doesn't line up 1-1. could be as simple as copying stair's global_rotation.y to the 2d rotation of the canvas item

Notes:
* Collision returns object to the `currentIndex`, not the `startIndex`
* Manually wrap around 0 since quaternions are a fuck and we can just avoid them with indexed bases