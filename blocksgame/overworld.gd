extends Node3D

@onready var player: Node3D = $PlayerArrow


func _ready() -> void:
	# Al volver de un dungeon, la flecha reaparece frente a la entrada que usó.
	if GameState.has_return_position:
		player.global_position = GameState.return_position
