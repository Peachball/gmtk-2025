extends Node2D

class_name Tile

var start := Vector2(inset, Constant.TILE_WIDTH / 2)
var mid := Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2)
var end := Vector2(Constant.TILE_WIDTH - inset, Constant.TILE_WIDTH / 2)
var line_thickness := 3
var inset := 2
var allow_rotate := true

var start_direction: int = Constant.Direction.LEFT
var end_direction: int = Constant.Direction.RIGHT
var grid_position: Vector2i

func init_random_direction() -> void:
	start_direction = Constant.Direction.LEFT
	
	var rand = randi() % 2
	if rand == 1:
		end_direction = Constant.Direction.DOWN
	else:
		end_direction = Constant.Direction.RIGHT
	init_from_directions(start_direction, end_direction)
	
func init_from_directions(new_start_direction: int, new_end_direction: int) -> void:
	start_direction = new_start_direction
	end_direction = new_end_direction
	Constant.direction_to_vector(start_direction)
	start = calculate_inset_vector(start_direction)
	end = calculate_inset_vector(end_direction)
	
func calculate_inset_vector(direction: int) -> Vector2:
	return mid + Constant.direction_to_vector(direction) * (Constant.TILE_WIDTH / 2 - inset)

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
	allow_rotate = false

	var angle := deg_to_rad(90)
	var start_offset = start - mid
	var end_offset = end - mid
	
	start_direction = (start_direction + 1) % 4
	end_direction = (end_direction + 1) % 4
	
	var tween := create_tween()
	
	tween.tween_method(
		func(t: float):
			start = start_offset.rotated(t * angle) + mid
			end = end_offset.rotated(t * angle) + mid
			queue_redraw()
	, 0.0, 1.0, 0.3)
	
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_callback(func(): allow_rotate = true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and allow_rotate:
		var local_mouse_pos = to_local(event.position)
		var tile_rect = Rect2(Vector2.ZERO, Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH))

		if tile_rect.has_point(local_mouse_pos):
			rotate_tile()
