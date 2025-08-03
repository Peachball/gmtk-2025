extends Node2D

var point_requirement := 25
var turn_limit := 10

var points: int:
	set(value):
		points = value
		$PointLabel.text = "Points: " + str(value) + " / " + str(point_requirement)
		
var turns: int:
	set(value):
		turns = value
		$TurnsLabel.text = "Turns: " + str(value)  + " / " + str(turn_limit)
		

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
			GAME_END:
				if points > point_requirement:
					$PopupPanel/EndingLabel.text = "~YOU WIN~"
				else: 
					$PopupPanel/EndingLabel.text = "WOMP WOMP"
				$PopupPanel.visible = true
				
		player_action = new_action
var start_player_position: Vector2i 

func _ready() -> void:
	$LevelLabel.text = "Level 1"
	start_player_position = Vector2i(0, $WorldMap.level_height - 1)
	$WorldMap.set_player_position(start_player_position)
	player_action = SLOT_MACHINE_PREROLL
	$SlotMachine.reroll()
	turns = 0
	$TurnsLabel.text = "Turns: " + str(turns) + " / " + str(turn_limit)
	points = 0
	$PointLabel.text = "Points: " + str(points) + " / " + str(point_requirement)
	$PopupPanel.visible = false

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
	
	if Input.is_action_just_pressed("click"):
		handle_place_tiles()

func handle_place_tiles() -> void:
	if $WorldMap.in_animation:
		return

	$ConfirmPlayerPathSound.play()
	var grid_map: Dictionary[Vector2i, Tile] = {}
	for child in $HeldTiles.get_children():
		var tile := child as Tile
		grid_map[tile.grid_position] = tile
	
	# Get tile under the player
	var relative_player_grid_position := Constant.NULL_GRID_POSITION
	var entry_direction := -1
	for grid_position in grid_map.keys():
		var tile := grid_map[grid_position]
		entry_direction = tile.end_direction if path_direction_flipped else tile.start_direction
		if tile.is_player_inside($WorldMap/Player.global_position):
			relative_player_grid_position = grid_position
			break
	if relative_player_grid_position == Constant.NULL_GRID_POSITION:
		return
	var path_history = _traverse_path(grid_map, relative_player_grid_position, entry_direction)

	var prev_player_position = $WorldMap.get_player_position()
	var modified_history = path_history.map(func (p):
		return Vector2i(prev_player_position + p - relative_player_grid_position))
	$WorldMap.move_player_along_path(modified_history as Array[Vector2i])

	clear_held_tiles()
	points += path_history.size() - 1
	turns += 1
	if turns >= turn_limit or points >= point_requirement:
		player_action = GAME_END
	else:
		player_action = SLOT_MACHINE_PREROLL
	player_action = SLOT_MACHINE_PREROLL
	
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

func _traverse_path(
		grid_map: Dictionary[Vector2i, Tile],
		start_pos: Vector2i,
		entry_direction: int,
		highlight_tiles: bool = true
	) -> Array:
	var current_pos := start_pos
	var current_direction := entry_direction
	var position_history: Array[Vector2i] = [current_pos]
	var seen_positions: Dictionary[Vector2i, bool] = {}

	while true:
		seen_positions[current_pos] = true
		var tile: Tile = grid_map.get(current_pos)
		if tile == null:
			break

		# Exit direction is where we leave this tile
		var exit_direction: int = tile.get_exit_direction(current_direction)
		if exit_direction == -1:
			break
			
		# Set highlights
		if highlight_tiles:
			if position_history.size() > 1: tile.set_highlight_direction(current_direction)
			tile.set_highlight_direction(exit_direction)

		# Move to next tile in that direction
		current_pos += Vector2i(Constant.direction_to_vector(exit_direction))
		
		# make sure new position is valid
		var new_map_position: Vector2i = current_pos - start_pos + $WorldMap.get_player_position()

		if !$WorldMap.is_position_in_bounds(new_map_position):
			break
		if !grid_map.has(current_pos):
			break
		if seen_positions.has(current_pos):
			position_history.append(current_pos)
			var last_tile: Tile = grid_map.get(current_pos)
			if highlight_tiles:
				last_tile.highlight_start = true
				last_tile.highlight_end = true
				last_tile.queue_redraw()
			break
		position_history.append(current_pos)
		current_direction = (exit_direction + 2) % 4  # reverse for next tile's entry		
	return position_history

func _on_roll_submit_button_pressed() -> void:
	$RollSubmitButtonSound.play()
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
			$RollSubmitButton.disabled = true
			$SlotRollingSound.play()
			for n in range(0, 20):
				await get_tree().create_timer(0.04).timeout
				$SlotMachine.reroll()
			$RollSubmitButton.disabled = false
			rolled = !rolled
