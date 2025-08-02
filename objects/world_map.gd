extends Node2D

@export
var level_width := 5
@export
var level_height := 5
var in_animation := false

func _ready() -> void:
	pass

func _draw() -> void:
	# draw grid lines
	for r in range(0, level_width + 1):
		draw_line(
			Vector2(0, r * Constant.TILE_WIDTH),
			Vector2((level_height) * Constant.TILE_WIDTH, r * Constant.TILE_WIDTH),
			Color.BLACK,
			Constant.LINE_THICKNESS,
			true
		)
	for c in range(0, level_height + 1):
		draw_line(
			Vector2(c * Constant.TILE_WIDTH, 0),
			Vector2(c * Constant.TILE_WIDTH, (level_width) * Constant.TILE_WIDTH),
			Color.BLACK,
			Constant.LINE_THICKNESS,
			true
		)

func set_player_position(position: Vector2i) -> void:
	$Player.position = Vector2((position.x + 0.5) * Constant.TILE_WIDTH,
		(position.y + .5) * Constant.TILE_WIDTH)

func move_player_along_path(positions: Array) -> void:
	if in_animation:
		return
	in_animation = true
	var tween := create_tween()
	for p in positions:
		tween.tween_property($Player, "position", Vector2((p.x + 0.5) * Constant.TILE_WIDTH,
			(p.y + .5) * Constant.TILE_WIDTH), 0.2)
	tween.tween_callback(func ():
		in_animation = false)
		
func get_player_position() -> Vector2i:
	return Vector2i(($Player.position / Constant.TILE_WIDTH).floor())
	
func is_position_in_bounds(p: Vector2i) -> bool:
	return (
		p.x < level_width and
		p.x >= 0 and
		p.y < level_height and
		p.y >= 0
	)
