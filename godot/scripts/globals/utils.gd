extends Node
# in all functions, X represents a float between 0 and 1

func normf(value: float, rangeStart: float, rangeEnd: float) -> float:
    return (value - rangeStart) / (rangeEnd - rangeStart)

func easeInOutCubic(x: float) -> float:
    if (x < 0.5):
        return 4 * x * x * x
    else:
        return 1 - ((-2 * x + 2) ** 3) / 2

func get_parent_level(node: Node) -> Level:
    var nodeParent = node.get_parent()
    if nodeParent is Level || nodeParent == null:
        return nodeParent
    else:
        return get_parent_level(nodeParent)

func get_children_of_type(parentNode: Node, type: Variant, recursive: bool = false):
    var foundChildren = []
    var allChildren = parentNode.get_children(true) if !recursive else parentNode.find_children("*")
    if allChildren.size() == 0: return foundChildren
    for nextChild in allChildren:
        if is_instance_of(nextChild, type):
            foundChildren.append(nextChild)
    return foundChildren

func get_children_in_group(parentNode: Node, groupName: String, recursive: bool = false):
    var foundChildren = []
    var allChildren = parentNode.find_children("*", "", recursive)
    if allChildren.size() == 0: return foundChildren
    for nextChild in allChildren:
        if nextChild.is_in_group(groupName):
            foundChildren.append(nextChild)
    return foundChildren
