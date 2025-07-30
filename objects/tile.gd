extends Node2D

class_name Tile

var end := 0
var line_thickness := 3
var inset := 2

func _ready() -> void:
	end = randi() % 2

func _draw() -> void:
	# draw box
	var rect_position = Vector2(0, 0)
	var rect_size = Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH)
	var my_rect = Rect2(rect_position, rect_size)
	
	var black = Color(0, 0, 0)
	var white = Color(1, 1, 1)
	
	draw_rect(my_rect, white , true)
	
	# Adjust position and size to account for border thickness
	var border_rect_position = rect_position - Vector2(line_thickness, line_thickness)
	var border_rect_size = rect_size + Vector2(line_thickness * 2, line_thickness * 2)
	draw_rect(Rect2(border_rect_position, border_rect_size), black, false, line_thickness)

	# draw path
	draw_line(
		Vector2(inset, Constant.TILE_WIDTH / 2),
		Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2),
		black,
		line_thickness
	)
	if end == 0:
		draw_line(
			Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2),
			Vector2(Constant.TILE_WIDTH - inset, Constant.TILE_WIDTH / 2),
			black,
			line_thickness
		)
	else:
		draw_line(
			Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2),
			Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH - inset),
			black,
			line_thickness
		)
	
