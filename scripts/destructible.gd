extends Area2D
class_name Destructible

var is_active: bool = true
var current_hp: float = 20.0
var damage: float = 0.0 # So players bumping it don't crash
@onready var color_rect = $ColorRect

func _ready() -> void:
    color_rect.color = Color(0.6, 0.4, 0.2, 1) # brown crate
    
func _physics_process(_delta: float) -> void:
    if is_active:
        CollisionManager.register(self, global_position, "enemy")

func take_damage(amt: float) -> void:
    if not is_active: return
    current_hp -= amt
    if current_hp <= 0:
        die()

func die() -> void:
    is_active = false
    var roll = randf()
    var ptype = ""
    if roll < 0.2: ptype = "heal"
    elif roll < 0.5: ptype = "gold"
    elif roll < 0.6: ptype = "magnet"
    elif roll < 0.65: ptype = "nuke"
    
    if ptype != "":
        var p_scene = preload("res://scenes/pickup.tscn")
        var p = p_scene.instantiate()
        p.pickup_type = ptype
        p.global_position = global_position
        get_tree().current_scene.add_child(p)
        
    queue_free()
