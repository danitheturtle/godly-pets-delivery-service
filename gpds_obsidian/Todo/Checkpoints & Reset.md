Checkpoints are:
* impassable to stairs
* the end goal of each level
* obvious from a distance
* distinct from platforms without requirement to adhere to puzzle grid.
* activated manually only once whole party is assembled

The reset hotkey takes the player and pet back to the last checkpoint and resets all platforms/stairs after the checkpoint to their initial position.
* do this programmatically with an array of changed node refs. gets cleared when player activates a checkpoint or resets, and keeps track of all objs they touch.