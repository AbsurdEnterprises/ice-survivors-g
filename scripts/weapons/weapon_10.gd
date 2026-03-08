extends WeaponBase
class_name Weapon10

var angle: float = 0.0
var rotate_speed: float = PI * 0.5 # 90 deg per sec
var beam_length: float = 800.0
var beam_width: float = 30.0

func _physics_process(delta: float) -> void:
    angle += rotate_speed * delta
    var dir = Vector2(cos(angle), sin(angle))
    
    var nearby = CollisionManager.get_nearby(player.global_position)
    for ent in nearby:
        if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
            var enemy = ent["node"]
            var to_enemy = enemy.global_position - player.global_position
            if to_enemy.length_squared() <= beam_length * beam_length:
                var proj = to_enemy.dot(dir)
                if proj > 0:
                    var perp_dist = abs(to_enemy.cross(dir))
                    if perp_dist <= beam_width:
                        enemy.apply_freeze(2.0)
                        
    queue_redraw()

func _draw() -> void:
    var end_pos = Vector2(cos(angle), sin(angle)) * beam_length
    draw_line(Vector2.ZERO, end_pos, Color(0, 0, 1, 0.5), beam_width)
