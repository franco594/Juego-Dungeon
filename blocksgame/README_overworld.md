# Overworld: primera versión

`map1.tscn` queda como escena principal y funciona como ciudad explorable en
tercera persona. La cámara sigue al personaje y puede orbitar con el mouse; el
GridMap genera colisiones al iniciar y el área `Salida` conduce a `map.tscn`.
Al salir del dungeon, el jugador vuelve a la posición guardada en la ciudad.

## Controles

- WASD o flechas: moverse
- Mouse: girar la cámara
- Shift: correr
- Espacio: saltar
- Escape: liberar el cursor; clic para capturarlo otra vez

## Modelo del personaje

La escena instancia `assets/MiniCharacter.glb` para que se pueda reemplazar por
un modelo propio. Para editarlo en Blender, importá el GLB, aplicá escala y
orientación, y exportá el modelo terminado como glTF Binary (`.glb`) con el
mismo nombre o actualizá la referencia `4_player` en `map1.tscn`.
