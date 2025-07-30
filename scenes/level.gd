extends Node2D

var points := 0

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
			SLOT_MACHINE_EDIT:
				$StateLabel.text = "Rotate the pieces!"
			PLACE_TILE:
				$StateLabel.text = "Place the piece!"
		player_action = new_action
var player_position := Vector2i(0, 0)

func _ready() -> void:
	$WorldMap.set_player_position(player_position)
	player_action = SLOT_MACHINE_PREROLL


func _on_roll_button_pressed() -> void:
	player_action = SLOT_MACHINE_EDIT

func _on_submit_button_pressed() -> void:
	player_action = PLACE_TILE
