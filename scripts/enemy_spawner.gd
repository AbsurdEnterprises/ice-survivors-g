extends Node

@export var pool_path: NodePath
var pool: Node

@export var player_path: NodePath
var player: Node2D

var M_CAP: int = 500
var B_S: float = 8.0
var r: float = 0.12

var time_elapsed: float = 0.0
var spawn_timer: float = 0.0
var spawn_interval: float = 0.5 # check twice a second

func _ready() -> void:
    if !pool_path.is_empty():
        pool = get_node(pool_path)
    if !player_path.is_empty():
        player = get_node(player_path)

func _process(delta: float) -> void:
    if not is_instance_valid(player) or not is_instance_valid(pool):
        return
        
    time_elapsed += delta
    spawn_timer -= delta
    if spawn_timer <= 0:
        spawn_timer = spawn_interval
        do_spawn_cycle()

func get_surge(t_min: float) -> int:
    var s = 0
    if t_min >= 5.0 and t_min < 5.16: s += 40
    if t_min >= 10.0 and t_min < 10.16: s += 80
    if t_min >= 15.0 and t_min < 15.16: s += 120
    if t_min >= 20.0 and t_min < 20.16: s += 160
    if t_min >= 25.0 and t_min < 25.16: s += 200
    return s

func do_spawn_cycle() -> void:
    var t_min = time_elapsed / 60.0
    if t_min >= 30.0:
        return # Boss phase, stop standard spawns
        
    var surge = get_surge(t_min)
    var target_count = min(M_CAP, floor(B_S * pow(1.0 + r, t_min) + surge))
    
    var n_to_spawn = target_count - pool.active_enemies
    
    # Let's cap spawns per tick to avoid framedrops
    n_to_spawn = min(n_to_spawn, 20)
    
    for i in range(n_to_spawn):
        var enemy = pool.get_enemy()
        if enemy == null:
            break
            
        spawn_enemy(enemy, t_min)

func spawn_enemy(enemy: Node, t_min: float) -> void:
    var vp = get_viewport().get_visible_rect().size
    var hw = vp.x / 2.0
    var hh = vp.y / 2.0
    var theta = randf() * TAU
    
    var spawn_x = player.global_position.x + (hw + 64) * cos(theta)
    var spawn_y = player.global_position.y + (hh + 64) * sin(theta)
    
    # Stage 1 vertical constraint: clamped Y
    spawn_y = clamp(spawn_y, -300.0, 300.0)
    
    # HP and speed scaling
    var hp_mod = 1.0 + (t_min * 0.15)
    var speed_mod = 1.0 + (t_min * 0.02)
    
    # Class composition by time
    var e_class = get_random_class(t_min)
    
    enemy.activate(Vector2(spawn_x, spawn_y), e_class, hp_mod, speed_mod)

func get_random_class(t_min: float) -> String:
    var roll = randf()
    if t_min < 3.0:
        return "fodder_01"
    elif t_min < 7.0:
        if roll < 0.60: return "fodder_01"
        return "erratic_02"
    elif t_min < 12.0:
        if roll < 0.40: return "fodder_01"
        elif roll < 0.70: return "erratic_02"
        return "fodder_01" # TODO: tank and ranged not added yet
    else:
        # Fallback for now until others are added
        if roll < 0.50: return "fodder_01"
        return "erratic_02"
