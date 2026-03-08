extends Area2D
class_name Hazard

var velocity: Vector2
var damage: float = 50.0

func _ready() -> void:
    $ColorRect.color = Color(1, 1, 0, 1) # Yellow
    $ColorRect.size = Vector2(64, 400)
    $ColorRect.position = Vector2(-32, -200)
    $CollisionShape2D.shape.size = Vector2(64, 400)

func _physics_process(delta: float) -> void:
    global_position += velocity * delta
    
    var nearby = CollisionManager.get_nearby(global_position)
    var my_rect = Rect2(global_position.x - 32, global_position.y - 200, 64, 400)
    for ent in nearby:
        if ent["type"] == "enemy" and ent["node"].is_active:
           # hazards damage enemies? usually they do or don't.
           pass
           
    # despawn logic
    var vp = get_viewport().get_visible_rect().size
    var cam = get_viewport().get_camera_2d()
    var center = cam.global_position if cam else Vector2.ZERO
    if global_position.distance_squared_to(center) > vp.x * vp.x * 2.0:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        body.take_damage(damage)
