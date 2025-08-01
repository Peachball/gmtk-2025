extends Node

class_name Constant

const TILE_WIDTH := 64.0
const LINE_THICKNESS := 4.0

enum Direction { 
	UP, RIGHT, DOWN, LEFT
}

const DIRECTION_MAP = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

static func direction_to_vector(direction: int) -> Vector2:
	return DIRECTION_MAP[direction % 4]

static func clear_children(node: Node2D) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
