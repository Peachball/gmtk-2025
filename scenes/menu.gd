extends Node2D

var level_scene := preload("res://scenes/level.tscn")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_scene)
