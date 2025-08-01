extends Node2D

class_name SlotMachine

const MACHINE_WIDTH := 5
const MACHINE_HEIGHT := 5

@export var tile_scene: PackedScene


func _ready() -> void:
	reroll()
	
func reroll() -> void:
	Constant.clear_children($Tiles)
	for row in MACHINE_HEIGHT:
		for col in MACHINE_WIDTH:
			var tile := tile_scene.instantiate() as Tile
			tile.init_random_direction()
			tile.grid_position = Vector2i(col, row)
			var tile_size := Constant.TILE_WIDTH
			var pos_x := col * (tile_size)
			var pos_y := row * (tile_size)
			
			tile.position = Vector2(pos_x, pos_y)
			$Tiles.add_child(tile)
