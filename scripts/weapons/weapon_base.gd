extends Node2D
class_name WeaponBase

var weapon_id: String
var level: int = 1
var max_level: int = 8
var base_dmg: float
var cooldown: float
var current_cooldown: float = 0.0

var player: Node2D

func init(_id: String, _player: Node2D) -> void:
    weapon_id = _id
    player = _player
    var data = GameData.weapons[weapon_id]
    base_dmg = data["base_dmg"]
    cooldown = data["cooldown"]
    max_level = data["max_level"]

func _physics_process(delta: float) -> void:
    if cooldown > 0:
        current_cooldown -= delta
        if current_cooldown <= 0:
            fire()
            current_cooldown = cooldown

func fire() -> void:
    pass

func get_damage() -> float:
    var area_mult = 1.0 # TODO player modifiers
    var crit_mult = 1.0 # TODO luck
    var meta_dmg_bonus = 0.0
    if SaveManager.save_data.has("meta_upgrades") and SaveManager.save_data["meta_upgrades"].has("meta_01"):
        meta_dmg_bonus = SaveManager.save_data["meta_upgrades"]["meta_01"] * 0.05
    return base_dmg * (1.0 + (level - 1) * 0.25) * area_mult * crit_mult * (1.0 + meta_dmg_bonus)
