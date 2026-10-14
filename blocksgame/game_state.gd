extends Node

# Autoload: guarda lo que tiene que sobrevivir al cambiar entre el mapa del mundo
# y los lugares especiales (dungeons, edificios, etc.).

## Escena del mapa del mundo a la que se vuelve al salir de un lugar.
var escena_mundo := "res://map1.tscn"
## Si es true, al cargar el mundo la flecha aparece en `posicion_regreso`.
var hay_regreso := false
var posicion_regreso := Vector3.ZERO

var _cambiando := false


## Entra a un lugar especial y recuerda dónde reaparecer al volver.
func entrar_a(escena: String, regreso: Vector3) -> void:
	if _cambiando:
		return
	var actual := get_tree().current_scene
	if actual and actual.scene_file_path != "":
		escena_mundo = actual.scene_file_path
	hay_regreso = true
	posicion_regreso = regreso
	_cambiar_a(escena)


## Vuelve al mapa del mundo desde un dungeon.
func volver_al_mundo() -> void:
	_cambiar_a(escena_mundo)


func _cambiar_a(escena: String) -> void:
	if _cambiando:
		return
	_cambiando = true
	# Diferido: puede llamarse desde una señal de física (body_entered).
	_hacer_cambio.call_deferred(escena)


func _hacer_cambio(escena: String) -> void:
	var error := get_tree().change_scene_to_file(escena)
	if error != OK:
		push_error("No se pudo cargar la escena: %s" % escena)
	_cambiando = false
