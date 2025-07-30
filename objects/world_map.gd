extends Node2D

@export
var level_width := 5
@export
var level_height := 5

func _ready() -> void:
	set_player_position(2, 2)

func _draw() -> void:
	# draw grid lines
	for r in range(0, level_width + 1):
		draw_line(
			Vector2(0, r * Constant.TILE_WIDTH),
			Vector2((level_height) * Constant.TILE_WIDTH, r * Constant.TILE_WIDTH),
			Color.BLACK,
			1.0
		)
	for c in range(0, level_height + 1):
		draw_line(
			Vector2(c * Constant.TILE_WIDTH, 0),
			Vector2(c * Constant.TILE_WIDTH, (level_width) * Constant.TILE_WIDTH),
			Color.BLACK,
			1.0
		)

func set_player_position(x: int, y: int) -> void:
	$Player.position = Vector2((x + 0.5) * Constant.TILE_WIDTH, (level_height - y - .5) * Constant.TILE_WIDTH)
