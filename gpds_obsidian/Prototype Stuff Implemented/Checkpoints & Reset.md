Checkpoints are:
* the starting point and the end goal of each level
* impassable to stairs
* obvious from a distance
* distinct from platforms without requirement to adhere to puzzle grid.
* activated manually only once whole party is assembled
* Save the game when reached

SubCheckpoints:
* are in-between the start and end of the level
* save the game and can be locally reset to
* cannot be accessed from level select
* stairs can pass sub-checkpoints

The reset hotkey takes the player and pet back to the last checkpoint and resets all platforms/stairs the player has touched since the last reset.
* do this programmatically with an array of changed node refs. gets cleared when player activates a checkpoint or resets, and keeps track of all objs they touch.
* store the initial position at the time of adding object to touched array. Full reset can be done by reloading from [[Level Select]]