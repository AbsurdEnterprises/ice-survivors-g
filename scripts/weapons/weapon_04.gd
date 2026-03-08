extends WeaponBase
class_name Weapon04

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var base_dist = 200.0
    var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    var target_time = 1.0
    var speed = base_dist / target_time
    
    proj_pool.spawn_projectile(player.global_position, dir * speed, get_damage(), 3, target_time, true)
