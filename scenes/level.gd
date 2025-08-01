extends Node2D

var points := 0
var rolled := true
var path_direction_flipped := false

enum {
	SLOT_MACHINE_PREROLL,
	SLOT_MACHINE_EDIT,
	PLACE_TILE,
	GAME_END
}
var player_action :int:
	set(new_action):
		match new_action:
			SLOT_MACHINE_PREROLL:
				$StateLabel.text = "Roll"
				$RollSubmitButton.text = "Roll"
			SLOT_MACHINE_EDIT:
				$StateLabel.text = "Rotate the pieces!"
				$RollSubmitButton.text = "Submit"
			PLACE_TILE:
				$RollSubmitButton.text = "Roll"
				$StateLabel.text = "Place the piece!"
		player_action = new_action
var player_position := Vector2i(0, 0)

func _ready() -> void:
	$LevelLabel.text = "Level 1"
	$WorldMap.set_player_position(player_position)
	player_action = SLOT_MACHINE_PREROLL
	$SlotMachine.reroll()

func _process(delta: float) -> void:
	match player_action:
		PLACE_TILE:
			process_place_tile()

func process_place_tile() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var centered_position: Vector2 = mouse_pos - Vector2((Constant.TILE_WIDTH * $SlotMachine.MACHINE_HEIGHT) / 2, (Constant.TILE_WIDTH * $SlotMachine.MACHINE_WIDTH) / 2)
	var map_offset: Vector2 = $WorldMap.position
	$HeldTiles.position = (
		(centered_position - map_offset).snappedf(Constant.TILE_WIDTH) + map_offset
	)
	
	if Input.is_action_just_pressed("ui_cancel"):
		clear_held_tiles()
		player_action = SLOT_MACHINE_EDIT
		return
	highlight_path()
	
func clear_held_tiles():
	Constant.clear_children($HeldTiles)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_TAB:
			path_direction_flipped = !path_direction_flipped
			queue_redraw()


func highlight_path() -> void:
	var grid_map: Dictionary[Vector2i, Tile] = {}
	for child in $HeldTiles.get_children():
		var tile := child as Tile
		grid_map[tile.grid_position] = tile
		tile.clear_highlights()

	# Get tile under the player
	for grid_position in grid_map.keys():
		var tile := grid_map[grid_position]
		if tile.is_player_inside($WorldMap/Player.global_position):
			var direction := tile.end_direction if path_direction_flipped else tile.start_direction
			_traverse_path(grid_map, grid_position, direction)
			break
		# var entry_direction := tile.calculate_path_direction($WorldMap/Player.global_position)
		# if entry_direction != -1:
			# _traverse_path(grid_map, grid_position, entry_direction)
			# break
			
func _traverse_path(grid_map: Dictionary[Vector2i, Tile], start_pos: Vector2i, entry_direction: int) -> void:
	var current_pos := start_pos
	var current_direction := entry_direction
	var path_length = 0

	while true:
		var tile: Tile = grid_map.get(current_pos)
		if tile == null:
			break

		# Exit direction is where we leave this tile
		var exit_direction: int = tile.get_exit_direction(current_direction)
		if exit_direction == -1:
			break
			
		# Set highlights
		if path_length > 0: tile.set_highlight_direction(current_direction)
		tile.set_highlight_direction(exit_direction)

		# Move to next tile in that direction
		current_pos += Vector2i(Constant.direction_to_vector(exit_direction))
		current_direction = (exit_direction + 2) % 4  # reverse for next tile's entry
		
		path_length += 1


func _on_roll_submit_button_pressed() -> void:
	match player_action:
		SLOT_MACHINE_EDIT:
			var tile_inst = preload("res://objects/tile.tscn")
			var tiles = $SlotMachine/Tiles
			clear_held_tiles()
			for tile in tiles.get_children():
				var casted_tile = tile as Tile
				var new_tile := tile_inst.instantiate()
				new_tile.allow_rotate = false
				new_tile.init_from_directions(casted_tile.start_direction, casted_tile.end_direction)
				new_tile.position = casted_tile.position
				new_tile.grid_position = casted_tile.grid_position
				new_tile.out_of_focus = true
				$HeldTiles.add_child(new_tile)
			player_action = PLACE_TILE
			rolled = !rolled
		SLOT_MACHINE_PREROLL:
			player_action = SLOT_MACHINE_EDIT
			for n in range(0, 25):
				await get_tree().create_timer(0.1).timeout
				$SlotMachine.reroll()
			rolled = !rolled
