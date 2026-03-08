extends WeaponBase
class_name Weapon08

func fire() -> void:
    var nearby = CollisionManager.get_nearby(player.global_position)
    var enemies = []
    for ent in nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            enemies.append(ent["node"])
            
    if enemies.is_empty(): return
    
    var target = enemies[randi() % enemies.size()]
    var dmg = get_damage()
    
    # AoE explosion at target position
    var explode_pos = target.global_position
    var radius = 64.0
    var sq_radius = radius * radius
    
    var all_nearby = CollisionManager.get_nearby(explode_pos)
    for ent in all_nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            if explode_pos.distance_squared_to(ent["node"].global_position) <= sq_radius:
                ent["node"].take_damage(dmg)
    
    # Visual feedback could be a simple temporary sprite, but we just want systems for V1.
