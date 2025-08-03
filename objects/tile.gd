extends Node2D

class_name Tile

var start := Vector2(inset, Constant.TILE_WIDTH / 2)
var mid := Vector2(Constant.TILE_WIDTH / 2, Constant.TILE_WIDTH / 2)
var end := Vector2(Constant.TILE_WIDTH - inset, Constant.TILE_WIDTH / 2)
var line_thickness := 5
var inset := 2
var allow_rotate := true
const highlight_color := Color.MEDIUM_AQUAMARINE

var start_direction: int = Constant.Direction.LEFT
var end_direction: int = Constant.Direction.RIGHT
var grid_position: Vector2i
var highlight_start: bool = false
var highlight_end: bool = false
var out_of_focus: bool:
	set(value):
		out_of_focus = value
		queue_redraw()

func _init():
	out_of_focus = false

var debug_box: PackedVector2Array = PackedVector2Array()

func init_random_direction() -> void:
	var directions := [Constant.Direction.UP, Constant.Direction.RIGHT, Constant.Direction.DOWN, Constant.Direction.LEFT]

	# Pick random start direction
	start_direction = directions[randi() % directions.size()]

	# Remove start_direction from the list to avoid duplication
	var remaining_directions = directions.duplicate()
	remaining_directions.erase(start_direction)

	# Pick random end direction from the remaining ones
	end_direction = remaining_directions[randi() % remaining_directions.size()]

	init_from_directions(start_direction, end_direction)

func init_from_directions(new_start_direction: int, new_end_direction: int) -> void:
	start_direction = new_start_direction
	end_direction = new_end_direction
	Constant.direction_to_vector(start_direction)
	start = calculate_inset_vector(start_direction)
	end = calculate_inset_vector(end_direction)
	
func calculate_inset_vector(direction: int) -> Vector2:
	return mid + Constant.direction_to_vector(direction) * (Constant.TILE_WIDTH / 2 - inset)

func set_highlight_direction(direction: int, highlight_state: bool = true) -> void:
	if start_direction == direction:
		highlight_start = highlight_state
	if end_direction == direction:
		highlight_end = highlight_state
	queue_redraw()
	
func clear_highlights() -> void:
	highlight_start = false
	highlight_end = false
	queue_redraw()
	
func is_player_inside(player_position: Vector2) -> bool:
	var tile_rect = Rect2(global_position, Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH))
	return tile_rect.has_point(player_position)

func _draw() -> void:
	# draw box
	var rect_position = Vector2(0, 0)
	var rect_size = Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH)
	var my_rect = Rect2(rect_position, rect_size)
	
	var black = Color(0, 0, 0)
	var white = Color(1, 1, 1)
	if out_of_focus:
		black = Color(0, 0, 0, 0.5)
		white = Color(1, 1, 1, 0)
	
	draw_rect(my_rect, white, true)
	
	# Adjust position and size to account for border thickness
	var border_rect_position = rect_position - Vector2(line_thickness, line_thickness)
	var border_rect_size = rect_size + Vector2(line_thickness * 2, line_thickness * 2)
	draw_rect(Rect2(border_rect_position, border_rect_size), black, false, line_thickness)

	# draw path
	draw_path(start, mid, highlight_start)
	draw_path(mid, end, highlight_end)

	if debug_box.size() >= 3:
		draw_colored_polygon(debug_box, Color.RED)

func draw_path(a: Vector2, b: Vector2, highlight: bool):
	var color = Color(0, 0, 0)
	if highlight:
		color = highlight_color
	if out_of_focus and color != highlight_color:
		color.a = 0.5
	draw_line(a, b, color, line_thickness)
	
func rotate_tile() -> void:
	$"Tile Rotate Sound".play()
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
	
func get_exit_direction(entry_direction: int) -> int:
	if entry_direction == start_direction:
		return end_direction
	elif entry_direction == end_direction:
		return start_direction
	return -1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and allow_rotate:
		var local_mouse_pos = to_local(event.position)
		var tile_rect = Rect2(Vector2.ZERO, Vector2(Constant.TILE_WIDTH, Constant.TILE_WIDTH))

		if tile_rect.has_point(local_mouse_pos):
			rotate_tile()
