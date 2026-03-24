Can't decide if this is actually necessary. Leaning towards not

The stair graph is a representation of all possible states of a level.

Every sub-level has its own StairGraph generated at runtime

Every platform has its own StairGraphNode, representing it in the overall stair graph.

The StairGraphNode's core job is to maintain a set of all its possible StairGraphEdges.

A StairGraphEdge exists between two Platforms and how many staircase slots are between them (staircase slots can be filled by connecting 2 adjacent stairs and rotating them together into place. see [[Two stairs that meet end-to-end connect]])

Edges have refs to Nodes.

Nodes have refs to all nodes they are connected to

When the player rotates a platform, connected staircases are removed from their existing edges and put onto the next edge

A full edge guaruntees platforms are connected

A staircase rotated into an edge that does not exist creates a temporary null-terminated edge

Make use of pass by reference so that the parent stair graph has refs to everything and each platform has a ref to the same edge if they share it