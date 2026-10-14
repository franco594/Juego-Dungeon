# BlocksGame / Juego-Dungeon

## Escenas
- `map1.tscn` – Mapa del mundo (ciudad), estilo SMT III. Escena principal.
- `map.tscn` – Dungeon en primera persona.
- `player_arrow.tscn` – Flecha del jugador en el mapa del mundo.
- `entrada.tscn` – Lugar especial reutilizable (marcador verde + nombre).

## Mapa del mundo
- La flecha se mueve libre, pero **solo sobre las calles** del GridMap: los items
  `Road02`–`Road07` de `CityMap.tres`. `Road01` (suelo gris) y los edificios no se
  pisan. La lista se cambia en el Inspector de la flecha (propiedad `calles`).
- Pintar más calles en el GridMap alcanza: no hay que tocar código ni colisiones.
- Cámara fija e inclinada (`camera_follow.gd`, propiedad `desplazamiento`).

### Agregar un lugar nuevo
1. Arrastrar `entrada.tscn` a `map1.tscn` y ubicarla sobre el edificio.
2. En el Inspector: `nombre_lugar`, `destino` (la escena a la que lleva),
   `punto_regreso` (dónde reaparece la flecha al volver: sobre una calle y fuera
   del área) y `altura_marcador`.
3. Para cambiar el tamaño del área: clic derecho > *Hijos editables* y ajustar la
   CollisionShape3D. Con `entrar_al_tocar` se entra sin apretar nada.

## Controles (Proyecto > Configuración > Mapa de entrada)
| Acción | Teclado | Joystick |
|---|---|---|
| mover_* | WASD / flechas | stick izq. / cruceta |
| correr | Shift | B |
| interactuar | E / Enter / Espacio | A |
| volver_mundo (dungeon) | Q | Back |

## Carpeta `_sin_usar/`
Archivos que no usa ninguna escena (generador de ciudad, versión en tercera
persona, modelos sin usar). Tiene un `.gdignore`, así que Godot no la importa.
Para recuperar algo, moverlo de vuelta a la raíz.
