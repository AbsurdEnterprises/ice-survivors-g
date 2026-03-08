extends CharacterBody2D
class_name Boss

var boss_id: String
var max_hp: float = 1000.0
var current_hp: float = 1000.0
var speed: float = 60.0
var damage: float = 25.0
var is_active: bool = false
var xp_value: int = 200

var ability_timer: float = 0.0

@onready var color_rect: ColorRect = $ColorRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var target: Node2D

func _ready() -> void:
    if get_tree().has_group("player"):
        target = get_tree().get_nodes_in_group("player")[0]
        
func activate(start_pos: Vector2, b_id: String, hp_mod: float) -> void:
    global_position = start_pos
    boss_id = b_id
    is_active = true
    visible = true
    set_physics_process(true)
    $CollisionShape2D.set_deferred("disabled", false)
    
    match boss_id:
        "boss_01":
            max_hp = 500.0 * hp_mod * 10
            speed = 60.0
            damage = 25.0
            color_rect.color = Color(0.5, 0, 0.5, 1) # Purple
            color_rect.size = Vector2(64, 64)
            color_rect.position = Vector2(-32, -32)
            collision_shape.shape.size = Vector2(64, 64)
            ability_timer = 4.0
        "boss_02":
            max_hp = 500.0 * hp_mod * 20
            speed = 40.0
            damage = 30.0
            color_rect.color = Color(0.8, 0, 0, 1) # Dark red
            color_rect.size = Vector2(80, 80)
            color_rect.position = Vector2(-40, -40)
            collision_shape.shape.size = Vector2(80, 80)
            ability_timer = 3.0
        "boss_final":
            max_hp = 99999999.0
            speed = 300.0 # Faster than player usually
            damage = 99999.0
            color_rect.color = Color(0, 0, 0, 1) # Black
            color_rect.size = Vector2(2000, 2000)
            color_rect.position = Vector2(-1000, -1000)
            collision_shape.shape.size = Vector2(2000, 2000)
            
    current_hp = max_hp
    
    if get_tree().has_group("hud"):
        get_tree().get_nodes_in_group("hud")[0].show_boss_hp(current_hp, max_hp)

func _physics_process(delta: float) -> void:
    if not is_active or not is_instance_valid(target):
        return
        
    var dir = (target.global_position - global_position).normalized()
    velocity = dir * speed
    move_and_slide()
    
    CollisionManager.register(self, global_position, "enemy")
    
    if boss_id == "boss_01" or boss_id == "boss_02":
        ability_timer -= delta
        if ability_timer <= 0:
            if boss_id == "boss_01":
                spawn_drones()
                ability_timer = 4.0
            elif boss_id == "boss_02":
                fire_aoe()
                ability_timer = 3.0

func spawn_drones() -> void:
    var spawner = get_tree().get_first_node_in_group("spawner")
    if spawner:
        for i in range(3):
            var enemy = spawner.pool.get_enemy()
            if enemy:
                enemy.activate(global_position + Vector2(randf_range(-30,30), randf_range(-30,30)), "fodder_01", 3.0, 5.0)

func fire_aoe() -> void:
    # Uses weapon 08's logic or spawner
    var dmg = 20.0
    var explode_pos = target.global_position
    var radius = 96.0
    var sq_radius = radius * radius
    
    # Just an instant AoE for MVP
    if target.global_position.distance_squared_to(explode_pos) <= sq_radius:
        target.take_damage(dmg)

func take_damage(amount: float) -> void:
    if not is_active: return
    current_hp -= amount
    
    var dmg_scene = preload("res://scenes/damage_number.tscn")
    var dmg = dmg_scene.instantiate()
    get_tree().current_scene.add_child(dmg)
    dmg.setup(int(amount), false)
    dmg.global_position = global_position
    
    if get_tree().has_group("hud"):
        get_tree().get_nodes_in_group("hud")[0].update_boss_hp(current_hp, max_hp)
        
    if current_hp <= 0:
        die()

func die() -> void:
    GameData.add_kill()
    if boss_id != "boss_final":
        var chest_scene = preload("res://scenes/treasure_chest.tscn")
        var chest = chest_scene.instantiate()
        chest.global_position = global_position
        get_tree().current_scene.add_child(chest)
        
        if get_tree().has_group("hud"):
            get_tree().get_nodes_in_group("hud")[0].hide_boss_hp()
            
        target.arena_locked = false
        var cam = get_viewport().get_camera_2d()
        if cam: cam.is_locked = false
            
    is_active = false
    visible = false
    set_physics_process(false)
    $CollisionShape2D.set_deferred("disabled", true)
    queue_free()
