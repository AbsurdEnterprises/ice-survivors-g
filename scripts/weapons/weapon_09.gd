extends WeaponBase
class_name Weapon09

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
    var dmg = get_damage()
    
    proj_pool.spawn_projectile(player.global_position, dir * 400.0, dmg, 999, 10.0, false, true)
