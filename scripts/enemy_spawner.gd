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

var boss_1_spawned: bool = false
var boss_2_spawned: bool = false
var boss_final_spawned: bool = false

var destructible_timer: float = 5.0

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

    destructible_timer -= delta
    if destructible_timer <= 0:
        destructible_timer = randf_range(5.0, 10.0)
        spawn_destructible()

func spawn_destructible() -> void:
    var d_scene = preload("res://scenes/destructible.tscn")
    var d = d_scene.instantiate()
    get_tree().current_scene.add_child(d)
    d.global_position = get_spawn_position()

func get_spawn_position() -> Vector2:
    var vp = get_viewport().get_visible_rect().size
    var hw = vp.x / 2.0
    var hh = vp.y / 2.0
    var theta = randf() * TAU
    var spawn_x = player.global_position.x + (hw + 64) * cos(theta)
    var spawn_y = player.global_position.y + (hh + 64) * sin(theta)
    return Vector2(spawn_x, clamp(spawn_y, -300.0, 300.0))

func get_surge(t_min: float) -> int:
    var s = 0
    if t_min >= 5.0 and t_min < 5.16: s += 40
    if t_min >= 10.0 and t_min < 10.16: s += 80
    if t_min >= 15.0 and t_min < 15.16: s += 120
    if t_min >= 20.0 and t_min < 20.16: s += 160
    if t_min >= 25.0 and t_min < 25.16: s += 200
    return s

func spawn_boss(b_id: String, t_min: float) -> void:
    var boss_scene = preload("res://scenes/boss.tscn")
    var boss = boss_scene.instantiate()
    var vp = get_viewport().get_visible_rect().size
    var spawn_pos = player.global_position + Vector2(0, -vp.y/2 + 100)
    get_tree().current_scene.add_child(boss)
    var hp_mod = 1.0 + (t_min * 0.15)
    boss.activate(spawn_pos, b_id, hp_mod)
    
    var cam = get_viewport().get_camera_2d()
    if cam: 
        cam.is_locked = true
        if cam.has_method("apply_shake"): cam.apply_shake(30.0)
        
    player.arena_locked = true
    var cam_pos = cam.global_position if cam else player.global_position
    player.arena_rect = Rect2(cam_pos - vp/2, vp)

func get_random_class(t_min: float) -> String:
    var roll = randf()
    if t_min < 3.0:
        return "fodder_01"
    elif t_min < 7.0:
        if roll < 0.60: return "fodder_01"
        elif roll < 0.95: return "erratic_02"
        return "ranged_04"
    elif t_min < 12.0:
        if roll < 0.40: return "fodder_01"
        elif roll < 0.70: return "erratic_02"
        elif roll < 0.85: return "tank_03"
        return "ranged_04"
    elif t_min < 20.0:
        if roll < 0.25: return "fodder_01"
        elif roll < 0.50: return "erratic_02"
        elif roll < 0.75: return "tank_03"
        return "ranged_04"
    else:
        if roll < 0.15: return "fodder_01"
        elif roll < 0.35: return "erratic_02"
        elif roll < 0.65: return "tank_03"
        return "ranged_04"

func spawn_hazard() -> void:
    var haz_scene = preload("res://scenes/hazard.tscn")
    var haz = haz_scene.instantiate()
    var vp = get_viewport().get_visible_rect().size
    var cam = get_viewport().get_camera_2d()
    var center = cam.global_position if cam else player.global_position
    
    var side = randi() % 2
    var y_offset = randf_range(-vp.y/2.0, vp.y/2.0)
    var x_offset = (vp.x/2.0 + 300.0) * (1 if side == 0 else -1)
    
    haz.global_position = center + Vector2(x_offset, y_offset)
    haz.velocity = Vector2(-2 if side == 0 else 2, 0) * 400.0
    
    get_tree().current_scene.add_child(haz)

func do_spawn_cycle() -> void:
    var t_min = time_elapsed / 60.0
    
    if t_min >= 10.0 and not boss_1_spawned:
        spawn_boss("boss_01", t_min)
        boss_1_spawned = true
    if t_min >= 20.0 and not boss_2_spawned:
        spawn_boss("boss_02", t_min)
        boss_2_spawned = true
    if t_min >= 30.0 and not boss_final_spawned:
        spawn_boss("boss_final", t_min)
        boss_final_spawned = true
        
    if t_min >= 30.0:
        return # Boss phase, stop standard spawns
        
    var surge = get_surge(t_min)
    
    var haz_prob = 0.0
    if t_min >= 7.0 and t_min < 12.0: haz_prob = 0.05
    elif t_min >= 12.0 and t_min < 20.0: haz_prob = 0.10
    elif t_min >= 20.0: haz_prob = 0.15
    if randf() < haz_prob:
        spawn_hazard()
        
    var m_cap = 300
    var b_s = 10.0
    var r_mod = 0.05
    var n_t = min(m_cap, floor(b_s * pow(1.0 + r_mod, time_elapsed / 60.0) + surge))
    
    var active_enemies = 0
    if pool.has_method("get_active_count"): active_enemies = pool.get_active_count()
    elif "active_enemies" in pool: active_enemies = pool.active_enemies
    
    if active_enemies < n_t:
        var to_spawn = min(20, n_t - active_enemies) # max batched spawns per cycle
        for i in range(to_spawn):
            var enemy = pool.get_enemy()
            if enemy:
                spawn_enemy(enemy, t_min)

func spawn_enemy(enemy: Node, t_min: float) -> void:
    var spawn_pos = get_spawn_position()
    
    var hp_mod = 1.0 + (t_min * 0.15)
    var speed_mod = 1.0 + (t_min * 0.02)
    var e_class = get_random_class(t_min)
    
    enemy.activate(spawn_pos, e_class, hp_mod, speed_mod)
