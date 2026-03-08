extends CharacterBody2D

var base_speed: float = 135.0 # default from char_01
var max_hp: float = 120.0
var current_hp: float = 120.0
var xp_radius: float = 64.0

var is_invulnerable: bool = false
var i_frame_timer: float = 0.0
var blink_timer: float = 0.0
var armor: float = 0.0

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
    current_hp = max_hp
    if get_tree().has_group("hud"):
        get_tree().get_nodes_in_group("hud")[0].update_hp(current_hp, max_hp)

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * base_speed
	move_and_slide()
	global_position.y = clamp(global_position.y, -300.0, 300.0)
	
	if is_invulnerable:
		i_frame_timer -= delta
		blink_timer -= delta
		if blink_timer <= 0:
			color_rect.visible = not color_rect.visible
			blink_timer = 0.05
		if i_frame_timer <= 0:
			is_invulnerable = false
			color_rect.visible = true
	else:
		check_enemy_collisions()

func check_enemy_collisions() -> void:
	var nearby = CollisionManager.get_nearby(global_position)
	var my_rect = Rect2(global_position.x - 16, global_position.y - 16, 32, 32)
	for ent in nearby:
		if ent["type"] == "enemy" and is_instance_valid(ent["node"]) and ent["node"].is_active:
			var enemy = ent["node"]
			# Simple distance check for fast collision (circle approx)
			if global_position.distance_squared_to(enemy.global_position) < 400.0: # ~20px overlap
				take_damage(enemy.damage)
				break

func take_damage(base_dmg: float) -> void:
	var spawner = get_tree().get_first_node_in_group("spawner")
	var t_min = 0.0
	if spawner: t_min = spawner.time_elapsed / 60.0
	
	var damage_taken = max(1.0, base_dmg * (1.0 + t_min * 0.08) - armor)
	current_hp -= damage_taken
	
	if get_tree().has_group("hud"):
		get_tree().get_nodes_in_group("hud")[0].update_hp(current_hp, max_hp)
	
	if current_hp <= 0:
		die()
	else:
		is_invulnerable = true
		i_frame_timer = 0.5
		blink_timer = 0.05

func die() -> void:
	print("Game Over")
	get_tree().paused = true
