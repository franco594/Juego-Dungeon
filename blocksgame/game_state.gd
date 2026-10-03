extends Node

# Autoload: guarda lo que debe sobrevivir al cambiar entre la ciudad y los dungeons.

var has_return_position := false
var return_position := Vector3.ZERO


func enter_dungeon(scene_path: String, back_position: Vector3) -> void:
	has_return_position = true
	return_position = back_position
	get_tree().change_scene_to_file.call_deferred(scene_path)


func return_to_overworld() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file.call_deferred("res://overworld.tscn")
