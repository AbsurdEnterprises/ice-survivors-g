extends WeaponBase
class_name Weapon01

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var dir = player.velocity.normalized()
    if dir == Vector2.ZERO: dir = Vector2.RIGHT
    var dmg = get_damage()
    
    # Sweep acts as a short piercing projectile
    proj_pool.spawn_projectile(player.global_position, dir * 600.0, dmg, 999, 0.15)
