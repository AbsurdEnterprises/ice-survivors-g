extends Node2D
class_name DamageNumber

var velocity := Vector2(0, -60)
var lifetime := 0.8
var fade_speed := 3.0
@onready var label: Label = $Label

func setup(amount: int, is_crit: bool = false) -> void:
    label.text = str(amount)
    if is_crit:
        modulate = Color(1.0, 0.8, 0.2)
        scale = Vector2(1.5, 1.5)

func _process(delta: float) -> void:
    global_position += velocity * delta
    lifetime -= delta
    if lifetime <= 0.3:
        modulate.a -= fade_speed * delta
    if lifetime <= 0:
        queue_free()
