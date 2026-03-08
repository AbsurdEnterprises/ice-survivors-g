extends WeaponBase
class_name Evo02

func _physics_process(delta: float) -> void:
    # Zero cooldown continuous piercing beam
    fire()

func fire() -> void:
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var dir = player.velocity.normalized()
    if dir == Vector2.ZERO: dir = Vector2.RIGHT
    var dmg = get_damage()
    
    # Needs to be continuous, we fire a fast projectile every frame with 0.1s lifetime
    proj_pool.spawn_projectile(player.global_position, dir * 800.0, dmg, 999, 0.1)
