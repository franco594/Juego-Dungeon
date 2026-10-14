extends Node3D

# Mapa del mundo (ciudad), estilo SMT III: la flecha recorre las calles con
# la cámara fija desde arriba. Las entradas a lugares especiales son instancias
# de entrada.tscn. Las colisiones las genera el GridMap solo, a partir de la
# MeshLibrary (CityMap.tres ya trae una forma por item).

@onready var flecha: Node3D = $Flecha
@onready var nombre_zona: Label = $HUD/NombreZona

@export var nombre := "Ciudad"


func _ready() -> void:
	nombre_zona.text = nombre.to_upper()
	if GameState.hay_regreso:
		var p := GameState.posicion_regreso
		flecha.global_position = Vector3(p.x, flecha.global_position.y, p.z)
		GameState.hay_regreso = false
