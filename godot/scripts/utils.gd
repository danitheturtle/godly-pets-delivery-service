extends Node
# in all functions, X represents a float between 0 and 1

func normf(value: float, rangeStart: float, rangeEnd: float) -> float:
	return (value - rangeStart) / (rangeEnd - rangeStart)

func easeInOutCubic(x: float) -> float:
	if (x < 0.5):
		return 4 * x * x * x
	else:
		return 1 - ((-2 * x + 2) ** 3) / 2
