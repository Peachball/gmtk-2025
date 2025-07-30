extends Node2D

class_name SlotMachine

const MACHINE_WIDTH := 5
const MACHINE_HEIGHT := 5

@export var tile_scene: PackedScene
@export var tile_spacing := 5
	
func _ready() -> void:
	reroll()
	
func reroll() -> void:
	for row in MACHINE_HEIGHT:
		for col in MACHINE_WIDTH:
			var tile := tile_scene.instantiate()
			
			var tile_size := Constant.TILE_WIDTH
			var pos_x := col * (tile_size + tile_spacing)
			var pos_y := row * (tile_size + tile_spacing)
			
			tile.position = Vector2(pos_x, pos_y)
			add_child(tile)
