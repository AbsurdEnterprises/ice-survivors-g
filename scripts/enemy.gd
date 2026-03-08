extends CharacterBody2D
class_name Enemy

var enemy_class: String = "fodder_01"
var max_hp: float = 10.0
var current_hp: float = 10.0
var base_speed: float = 40.0
var knockback_resistance: float = 1.0 # higher is more resistant
var is_active: bool = false
var damage: float = 5.0
var xp_value: int = 1

# erratic_02 specific
var pause_timer: float = 0.0
var moving: bool = true

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target: Node2D

func _ready() -> void:
    if get_tree().has_group("player"):
        target = get_tree().get_nodes_in_group("player")[0]
        
func activate(start_pos: Vector2, e_class: String, hp_mod: float, speed_mod: float) -> void:
    global_position = start_pos
    enemy_class = e_class
    is_active = true
    visible = true
    set_physics_process(true)
    $CollisionShape2D.set_deferred("disabled", false)
    
    match enemy_class:
        "fodder_01":
            max_hp = 10.0 * hp_mod * 0.8
            base_speed = 40.0 * speed_mod
            damage = 5.0
            xp_value = 1
            color_rect.color = Color(1, 0, 0, 1) # Red
            color_rect.size = Vector2(24, 24)
            color_rect.position = Vector2(-12, -12)
            collision_shape.shape.size = Vector2(24, 24)
        "erratic_02":
            max_hp = 15.0 * hp_mod * 1.0
            base_speed = 55.0 * speed_mod
            damage = 8.0
            xp_value = 2
            color_rect.color = Color(1, 0.5, 0, 1) # Orange
            color_rect.size = Vector2(20, 20)
            color_rect.position = Vector2(-10, -10)
            collision_shape.shape.size = Vector2(20, 20)
            pause_timer = randf_range(1.0, 3.0)
            moving = true
    
    current_hp = max_hp

func deactivate() -> void:
    is_active = false
    visible = false
    set_physics_process(false)
    $CollisionShape2D.set_deferred("disabled", true)
    global_position = Vector2(-9999, -9999)
    if has_meta("pool"):
        get_meta("pool").return_enemy(self)

func _physics_process(delta: float) -> void:
    if not is_active or not is_instance_valid(target):
        return
        
    var dir = (target.global_position - global_position).normalized()
    
    if enemy_class == "erratic_02":
        pause_timer -= delta
        if pause_timer <= 0:
            moving = !moving
            if moving:
                pause_timer = randf_range(1.0, 3.0)
            else:
                pause_timer = randf_range(0.5, 2.0)
        
        if moving:
            velocity = dir * base_speed
        else:
            velocity = Vector2.ZERO
    else:
        # Default behavior (fodder_01)
        velocity = dir * base_speed
        
    move_and_slide()
    CollisionManager.register(self, global_position, "enemy")

func take_damage(amount: float) -> void:
    if not is_active: return
    current_hp -= amount
    if current_hp <= 0:
        die()

func die() -> void:
    if get_tree().has_group("xp_pool"):
        get_tree().get_first_node_in_group("xp_pool").spawn_gem(global_position, xp_value)
    deactivate()
