extends Area2D
class_name Projectile

var is_active: bool = false
var velocity: Vector2
var damage: float
var pierce_count: int = 1
var lifetime: float = 2.0
var hit_enemies: Array[Node] = []

var is_lob: bool = false
var lob_duration: float = 1.0
var time_lived: float = 0.0
var is_bouncing: bool = false

func activate(start_pos: Vector2, _vel: Vector2, _dmg: float, _pierce: int, _lifetime: float = 2.0, _lob: bool = false, _bounce: bool = false) -> void:
    global_position = start_pos
    velocity = _vel
    damage = _dmg
    pierce_count = _pierce
    is_active = true
    visible = true
    lifetime = _lifetime
    is_lob = _lob
    is_bouncing = _bounce
    lob_duration = _lifetime
    time_lived = 0.0
    hit_enemies.clear()
    $CollisionShape2D.set_deferred("disabled", false)
    
func deactivate() -> void:
    is_active = false
    visible = false
    $CollisionShape2D.set_deferred("disabled", true)
    global_position = Vector2(-9999, -9999)
    if has_meta("pool"):
        get_meta("pool").return_projectile(self)

func _physics_process(delta: float) -> void:
    if not is_active: return
    global_position += velocity * delta
    time_lived += delta
    lifetime -= delta
    if lifetime <= 0:
        deactivate()
        return
        
    queue_redraw()
    
    if is_lob and lifetime > 0.1: return
    
    if is_bouncing:
        var cam = get_viewport().get_camera_2d()
        if cam:
            var vp_size = get_viewport_rect().size
            var cpos = cam.global_position
            if global_position.x < cpos.x - vp_size.x/2 and velocity.x < 0: velocity.x *= -1
            elif global_position.x > cpos.x + vp_size.x/2 and velocity.x > 0: velocity.x *= -1
            if global_position.y < cpos.y - vp_size.y/2 and velocity.y < 0: velocity.y *= -1
            elif global_position.y > cpos.y + vp_size.y/2 and velocity.y > 0: velocity.y *= -1

    var nearby = CollisionManager.get_nearby(global_position)
    var my_rect = Rect2(global_position.x - 16, global_position.y - 16, 32, 32) if is_lob else Rect2(global_position.x - 4, global_position.y - 4, 8, 8)
    for ent in nearby:
        if ent["type"] == "enemy" and ent["node"].is_active:
            var enemy = ent["node"]
            if enemy in hit_enemies: continue
            var e_rect = Rect2(enemy.global_position + enemy.color_rect.position, enemy.color_rect.size)
            if my_rect.intersects(e_rect):
                enemy.take_damage(damage)
                hit_enemies.append(enemy)
                pierce_count -= 1
                if pierce_count <= 0:
                    deactivate()
                    break

func _draw() -> void:
    var offset_y = 0.0
    if is_lob:
        var t = clamp(time_lived / lob_duration, 0.0, 1.0)
        offset_y = -sin(t * PI) * 100.0
    draw_circle(Vector2(0, offset_y), 6.0 if is_lob else 4.0, Color(1, 1, 0))
