extends WeaponBase
class_name Evo05

var base_radius: float = 160.0

func _physics_process(delta: float) -> void:
    if cooldown > 0:
        current_cooldown -= delta
        if current_cooldown <= 0:
            fire()
            current_cooldown = cooldown

func fire() -> void:
    var dmg = get_damage()
    var missing_hp = player.max_hp - player.current_hp
    dmg += missing_hp * 0.1 # Scales with missing HP
    
    var area_mult = 1.0 # TODO player modifiers
    var radius = base_radius * 1.5 * area_mult
    var sq_radius = radius * radius
    
    var nearby = CollisionManager.get_nearby(player.global_position)
    var hit_count = 0
    for ent in nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            if player.global_position.distance_squared_to(ent["node"].global_position) <= sq_radius:
                ent["node"].take_damage(dmg)
                hit_count += 1
                
    if hit_count > 0:
        player.current_hp = min(player.max_hp, player.current_hp + (hit_count * 2.0))
        if get_tree().has_group("hud"):
            get_tree().get_nodes_in_group("hud")[0].update_hp(player.current_hp, player.max_hp)
