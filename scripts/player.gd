extends CharacterBody2D

var base_speed: float = 135.0 # default from char_01
var max_hp: float = 120.0
var current_hp: float = 120.0
var xp_radius: float = 64.0

var is_invulnerable: bool = false
var i_frame_timer: float = 0.0
var blink_timer: float = 0.0
var armor: float = 0.0

var current_xp: int = 0
var current_level: int = 1

@onready var color_rect: ColorRect = $ColorRect
@onready var pickup_area: Area2D = $PickupArea

func _ready() -> void:
    current_hp = max_hp
    if get_tree().has_group("hud"):
        var hud = get_tree().get_nodes_in_group("hud")[0]
        hud.update_hp(current_hp, max_hp)
        hud.update_xp(current_xp, get_xp_required(current_level))
        hud.update_level(current_level)

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
	
	check_xp_collection()

func check_xp_collection() -> void:
	if not is_instance_valid(pickup_area): return
	for area in pickup_area.get_overlapping_areas():
		if area.is_in_group("xp_gem") and area.is_active:
			gain_xp(area.xp_value)
			area.deactivate()

func get_xp_required(level: int) -> int:
	return floor(10.0 * pow(level, 1.5) + 50.0)

func gain_xp(amount: int) -> void:
	current_xp += amount
	var req = get_xp_required(current_level)
	while current_xp >= req:
		current_xp -= req
		current_level += 1
		req = get_xp_required(current_level)
		level_up()
		
	if get_tree().has_group("hud"):
		get_tree().get_nodes_in_group("hud")[0].update_xp(current_xp, req)

func level_up() -> void:
	if get_tree().has_group("hud"):
		get_tree().get_nodes_in_group("hud")[0].update_level(current_level)
	if get_tree().has_group("level_up"):
		var opts = 3 if current_level == 2 else 4
		get_tree().get_first_node_in_group("level_up").show_level_up(self, opts)
	
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
