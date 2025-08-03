extends Node2D

class_name SlotMachine

var machine_width := 5
var machine_height := 5

@export var tile_scene: PackedScene


func _ready() -> void:
	reroll()
	
func reroll() -> void:
	Constant.clear_children($Tiles)
	for row in machine_height:
		for col in machine_width:
			var tile := tile_scene.instantiate() as Tile
			tile.init_random_direction()
			tile.grid_position = Vector2i(col, row)
			var tile_size := Constant.TILE_WIDTH
			var pos_x := col * (tile_size)
			var pos_y := row * (tile_size)
			
			tile.position = Vector2(pos_x, pos_y)
			$Tiles.add_child(tile)
