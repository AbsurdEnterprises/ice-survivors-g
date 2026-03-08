extends WeaponBase
class_name Weapon06

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    # Ground pool: stationary lob projectile essentially, or stationary area
    var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    var start_pos = player.global_position + dir * randf_range(50, 150)
    
    # Use lob with 0 velocity and 3s lifetime to act as area pool
    proj_pool.spawn_projectile(start_pos, Vector2.ZERO, get_damage(), 999, 3.0, true)
