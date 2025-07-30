extends Node2D

class_name Tile

var start := Vector2(inset, Constant.TILE_WIDTH / 2)
var mid := Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2)
var end := Vector2(Constant.TILE_WIDTH - inset, Constant.TILE_WIDTH / 2)
var line_thickness := 3
var inset := 2
var allow_rotate := true

func _ready() -> void:
	start = Vector2(inset, Constant.TILE_WIDTH / 2)
	mid = Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2)
	var rand = randi() % 2
	if rand == 1:
		end = Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH - inset)
	

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
	draw_line(start, mid, black, line_thickness)
	draw_line(mid, end, black, line_thickness)
	
func rotate_tile() -> void:
	var angle := deg_to_rad(90)
	
	start = (start - mid).rotated(angle) + mid
	end = (end - mid).rotated(angle) + mid
	
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and allow_rotate:
		var local_mouse_pos = to_local(event.position)
		var tile_rect = Rect2(Vector2.ZERO, Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH))

		if tile_rect.has_point(local_mouse_pos):
			rotate_tile()
