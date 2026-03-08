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
var freeze_timer: float = 0.0

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
        "tank_03":
            max_hp = 40.0 * hp_mod * 5.0
            base_speed = 35.0 * speed_mod
            damage = 15.0
            xp_value = 10
            color_rect.color = Color(0, 0.4, 0, 1) # Dark green
            color_rect.size = Vector2(36, 36)
            color_rect.position = Vector2(-18, -18)
            collision_shape.shape.size = Vector2(36, 36)
            knockback_resistance = 100.0 # immune to kb mostly
        "ranged_04":
            max_hp = 20.0 * hp_mod * 1.2
            base_speed = 25.0 * speed_mod
            damage = 12.0
            xp_value = 5
            color_rect.color = Color(0, 1, 1, 1) # Cyan
            color_rect.size = Vector2(16, 16)
            color_rect.position = Vector2(-8, -8)
            collision_shape.shape.size = Vector2(16, 16)
            pause_timer = 3.0 # fire_timer
    
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
    elif enemy_class == "ranged_04":
        var dist = global_position.distance_to(target.global_position)
        var ideal_dist = 400.0
        
        if dist > ideal_dist + 10:
            velocity = dir * base_speed
        elif dist < ideal_dist - 10:
            velocity = -dir * base_speed
        else:
            # Orbit slowly
            var tangent = Vector2(-dir.y, dir.x)
            velocity = tangent * base_speed
            
        pause_timer -= delta
        if pause_timer <= 0:
            # fire projectile
            if get_tree().has_group("projectile_pool"):
                get_tree().get_first_node_in_group("projectile_pool").spawn_projectile(global_position, dir * 200, 12.0, 1)
            pause_timer = 3.0
    else:
        # tank_03 and fodder_01
        velocity = dir * base_speed
        
    if freeze_timer > 0:
        freeze_timer -= delta
        velocity = Vector2.ZERO
        
    move_and_slide()
    CollisionManager.register(self, global_position, "enemy")

func apply_freeze(duration: float) -> void:
    freeze_timer = max(freeze_timer, duration)

func take_damage(amount: float) -> void:
    if not is_active: return
    current_hp -= amount
    if current_hp <= 0:
        die()

func die() -> void:
    if get_tree().has_group("xp_pool"):
        get_tree().get_first_node_in_group("xp_pool").spawn_gem(global_position, xp_value)
    deactivate()
