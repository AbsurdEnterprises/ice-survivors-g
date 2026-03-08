extends WeaponBase
class_name Weapon03

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var dir = player.velocity.normalized()
    if dir == Vector2.ZERO: dir = Vector2.RIGHT
    var dmg = get_damage()
    
    var angles = [-0.15, 0.0, 0.15]
    for angle in angles:
        var p_dir = dir.rotated(angle)
        proj_pool.spawn_projectile(player.global_position, p_dir * 500.0, dmg, 1, 2.0)
