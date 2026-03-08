extends Node

const CELL_SIZE: int = 128
var grid: Dictionary = {}
func _ready() -> void:
    process_physics_priority = -100

func _physics_process(_delta: float) -> void:
    grid.clear()

func register(entity: Node, pos: Vector2, e_type: String) -> void:
    var cell = get_cell(pos)
    if not grid.has(cell):
        grid[cell] = []
    grid[cell].append({"node": entity, "pos": pos, "type": e_type})

func get_cell(pos: Vector2) -> Vector2i:
    return Vector2i(floor(pos.x / CELL_SIZE), floor(pos.y / CELL_SIZE))

func get_nearby(pos: Vector2) -> Array:
    var cell = get_cell(pos)
    var result = []
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            var c = cell + Vector2i(dx, dy)
            if grid.has(c):
                result.append_array(grid[c])
    return result
