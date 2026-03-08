extends Area2D
class_name XPGem

var is_active: bool = false
var xp_value: int = 1

func activate(start_pos: Vector2, val: int) -> void:
    global_position = start_pos
    xp_value = val
    is_active = true
    visible = true
    $CollisionShape2D.set_deferred("disabled", false)
    
func deactivate() -> void:
    is_active = false
    visible = false
    $CollisionShape2D.set_deferred("disabled", true)
    global_position = Vector2(-9999, -9999)
    if has_meta("pool"):
        get_meta("pool").return_gem(self)
