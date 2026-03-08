extends WeaponBase
class_name Weapon02

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var nearby = CollisionManager.get_nearby(player.global_position)
    var nearest = null
    var min_dist = INF
    for ent in nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            var dist = player.global_position.distance_squared_to(ent["node"].global_position)
            if dist < min_dist:
                min_dist = dist
                nearest = ent["node"]
                
    if nearest:
        var dir = (nearest.global_position - player.global_position).normalized()
        var dmg = get_damage()
        var speed = 400.0 # TODO player proj speed modifier
        proj_pool.spawn_projectile(player.global_position, dir * speed, dmg, 1)
