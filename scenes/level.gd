extends Node2D

var points := 0
var rolled := true

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
	$WorldMap.set_player_position(player_position)
	player_action = SLOT_MACHINE_PREROLL
	$SlotMachine.reroll()

func _process(delta: float) -> void:
	match player_action:
		PLACE_TILE:
			process_place_tile()

func process_place_tile() -> void:
	$HeldTiles.position = get_viewport().get_mouse_position()
	
	if Input.is_action_just_pressed("ui_cancel"):
		for child in $HeldTiles.get_children():
			$HeldTiles.remove_child(child)
			child.queue_free()
		player_action = SLOT_MACHINE_EDIT
		return
	

func _on_roll_submit_button_pressed() -> void:
	match player_action:
		SLOT_MACHINE_EDIT:
			var tile_inst = preload("res://objects/tile.tscn")
			var tiles = $SlotMachine/Tiles
			for tile in tiles.get_children():
				var casted_tile = tile as Tile
				var new_tile := tile_inst.instantiate()
				new_tile.allow_rotate = false
				new_tile.init_from_directions(casted_tile.start_direction, casted_tile.end_direction)
				new_tile.position = casted_tile.position
				new_tile.grid_position = casted_tile.grid_position
				$HeldTiles.add_child(new_tile)
			player_action = PLACE_TILE
			rolled = !rolled
		SLOT_MACHINE_PREROLL:
			player_action = SLOT_MACHINE_EDIT
			$SlotMachine.reroll()
			rolled = !rolled
