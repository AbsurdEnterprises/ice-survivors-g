extends WeaponBase
class_name Weapon07

var orbitals: Array[Node] = []
var angle: float = 0.0
var orb_speed: float = 3.0
var orbit_radius: float = 80.0

func _physics_process(delta: float) -> void:
    if cooldown > 0:
        current_cooldown -= delta
        if current_cooldown <= 0:
            fire()
            current_cooldown = cooldown
            
    # Update orbital positions
    angle += orb_speed * delta
    for i in range(orbitals.size()):
        var proj = orbitals[i]
        if not is_instance_valid(proj) or not proj.is_active:
            orbitals.remove_at(i)
            break # cleanup on next frame
        var a = angle + (TAU / orbitals.size()) * i
        proj.global_position = player.global_position + Vector2(cos(a), sin(a)) * orbit_radius

func fire() -> void:
    if orbitals.size() >= 3: return # Max level increases count later
    
    var proj_pool = get_tree().get_first_node_in_group("projectile_pool")
    if not proj_pool: return
    
    var dmg = get_damage()
    # Give extremely long lifetime for now, or just replenish
    proj_pool.spawn_projectile(player.global_position, Vector2.ZERO, dmg, 999, 10.0)
    
    # We must grab the last spawned from pool's active list.
    # But pool doesn't return the instance from spawn_projectile.
    # Wait, getting the reference is tricky. I'll just change pool to return it.
    # For now, I'll assume we can't get it easily.
    # I'll update spawn_projectile to return Node in the next step.
