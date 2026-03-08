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

var arena_locked: bool = false
var arena_rect: Rect2

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
	
	if arena_locked:
		global_position.x = clamp(global_position.x, arena_rect.position.x, arena_rect.end.x)
		global_position.y = clamp(global_position.y, arena_rect.position.y, arena_rect.end.y)
	else:
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
		elif area.is_in_group("treasure_chest"):
			open_chest()
			area.queue_free()
		elif area.is_in_group("pickup"):
			collect_pickup(area.pickup_type)
			area.queue_free()

func collect_pickup(ptype: String) -> void:
	match ptype:
		"heal":
			current_hp = min(max_hp, current_hp + 30.0)
			if get_tree().has_group("hud"):
				get_tree().get_nodes_in_group("hud")[0].update_hp(current_hp, max_hp)
		"gold":
			GameData.add_gold(10)
		"magnet":
			var gems = get_tree().get_nodes_in_group("xp_gem")
			for g in gems:
				if g.is_active:
					g.global_position = global_position
		"nuke":
			var enemies = get_tree().get_nodes_in_group("enemy")
			for e in enemies:
				if e.is_active and e.has_method("take_damage"):
					e.take_damage(99999.0)

func open_chest() -> void:
	var evolved = false
	var possible_evos = []
	for e in GameData.evolutions.values():
		var req_w = e["requires_weapon"]
		var req_p = e["requires_passive"]
		var has_w8 = false
		for w in weapons:
			if w.weapon_id == req_w and w.level >= w.max_level:
				has_w8 = true
				break
		var has_p = false
		if typeof(req_p) == TYPE_ARRAY:
			has_p = true
			for p in req_p:
				if not passives.has(p): has_p = false
		else:
			if passives.has(req_p): has_p = true
			
		if has_w8 and has_p:
			possible_evos.append(e)
			
	if possible_evos.size() > 0:
		var evo = possible_evos[0]
		for w in weapons:
			if w.weapon_id == evo["replaces"]:
				w.queue_free()
				weapons.erase(w)
				break
		add_or_upgrade_item(evo["id"], "weapon")
		evolved = true

	if not evolved:
		current_hp = max_hp
		is_invulnerable = true
		i_frame_timer = 10.0
		blink_timer = 0.05
		
	if get_tree().has_group("hud"):
		get_tree().get_nodes_in_group("hud")[0].update_hp(current_hp, max_hp)

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

var weapons: Array[Node] = []
var passives: Dictionary = {}

func add_or_upgrade_item(id: String, type: String) -> void:
	if type == "weapon":
		var found = false
		for w in weapons:
			if w.weapon_id == id:
				w.level = min(w.level + 1, w.max_level)
				found = true
				break
		if not found and weapons.size() < 6:
			var script_path = "res://scripts/weapons/" + id + ".gd"
			var w_script = load(script_path)
			if w_script:
				var w = Node2D.new()
				w.set_script(w_script)
				w.init(id, self)
				add_child(w)
				weapons.append(w)
	elif type == "passive":
		if passives.has(id):
			passives[id] = min(passives[id] + 1, 5)
		elif passives.size() < 6:
			passives[id] = 1
		apply_passives()

func apply_passives() -> void:
    # Base stats recalculation
	max_hp = 120.0
	base_speed = 135.0
	armor = 0.0
	xp_radius = 64.0
    
	for p_id in passives:
		var lvl = passives[p_id]
		var data = GameData.passives[p_id]
		var stat = data["stat"]
		var bonus = data["bonus_per_level"] * lvl
		match stat:
			"max_hp": max_hp *= (1.0 + bonus)
			"armor": armor += bonus
			"xp_radius": xp_radius *= (1.0 + bonus)
			"move_speed": base_speed *= (1.0 + bonus)
    # the rest of stats like cooldown_reduction are read by weapons dynamically
	
	if get_tree().has_group("hud"):
		get_tree().get_nodes_in_group("hud")[0].update_hp(current_hp, max_hp)
	
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
