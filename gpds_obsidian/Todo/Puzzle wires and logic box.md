Activable things (ghost platforms, force fields) need a unified API for activation
Activators (buttons, stair slots) need a unified API for activating

Need an easy-to-use PuzzleWire node with exported slots and toggleable logic. More than one activator could be required to shift the output positive.

For simplicity, each wire computes at most one logic calculation, no matter how many inputs and outputs it has. Example
* 2 activators, 2 activables, AND. Once both activators send WIRE_HIGH, activation signals are sent to both activables.
* 3 activators, 1 activable, OR. When any of the activators sends WIRE_HIGH, activate connected activable.

PuzzleWire can be put in another PuzzleWire as an activator if nested logic is needed.

Eventually PuzzleWires could be visualised somehow. Need an easy way to show the player what the actions they perform are doing.