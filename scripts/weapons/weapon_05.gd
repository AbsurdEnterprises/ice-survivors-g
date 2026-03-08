extends WeaponBase
class_name Weapon05

var base_radius: float = 80.0

func _physics_process(delta: float) -> void:
    if cooldown > 0:
        current_cooldown -= delta
        if current_cooldown <= 0:
            fire()
            current_cooldown = cooldown

func fire() -> void:
    var dmg = get_damage()
    var area_mult = 1.0 # TODO player modifiers
    var radius = base_radius * 1.5 * area_mult # base_area from data is 1.5
    var sq_radius = radius * radius
    
    var nearby = CollisionManager.get_nearby(player.global_position)
    for ent in nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            if player.global_position.distance_squared_to(ent["node"].global_position) <= sq_radius:
                ent["node"].take_damage(dmg)
