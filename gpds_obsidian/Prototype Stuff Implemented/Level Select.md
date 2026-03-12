* reset all levels after selected level so player isn't stuck when they finish
* 
* Each pet is associated with a world and the god at the end of it.
* Every world has many sequential levels.
* Every level starts with its own checkpoint and ends at the next level's checkpoint
	* optional sub-checkpoints for longer or more intricate levels.
* Via hotkey the player can open a 2d menu to quickly change levels, fully restart the current one, or go to the level select scene (placeholder for now).
* The player can select the world and level they play next from this UI or return to previous levels
* All objects in a level are grouped under it's root Node3D, which contains the level script

===

The level select scene is a 3d non-puzzle zone for progression NPCs and doors / portals to each level.

Scoring system eventually is displayed here.
* Track score for:
	* number of moves
	* stairs used
	* resets
- For the 3d level select, it would be cool to have some type of "visible from a distance" score representation for each level, letting the player collect-a-thon and light up all of them.

Build level select UI first. Easier and less fiddly. 3d representation can come later if it even happens.

Maybe there aren't portals, it just transitions you from a central area like the elden ring round table hold.

If levels are encoded programaticaly, the platforms and stairs could appear in sequence giving the appearance of the level "animating" into life. Could also just do this in sequence of distance to player when the scene inits. probably easier

Maybe the default state of the world is a big white void room with a grid with key objects acting as splashes of color / focal points