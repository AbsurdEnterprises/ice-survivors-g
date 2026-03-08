extends Node

var weapons = {}
var passives = {}
var evolutions = {}

func _ready():
    var w_data = [
        {"id": "weapon_01", "type": "melee_sweep", "name": "Melee Sweep", "base_dmg": 15, "max_level": 8, "description": "Horizontal sweep"},
        {"id": "weapon_02", "type": "auto_target", "name": "Auto Target", "base_dmg": 12, "max_level": 8, "description": "Fires projectile at nearest"},
        {"id": "weapon_03", "type": "directional_barrage", "name": "Barrage", "base_dmg": 8, "max_level": 8, "description": "Fires burst in movement"},
        {"id": "weapon_04", "type": "arcing_lob", "name": "Arcing Lob", "base_dmg": 22, "max_level": 8, "description": "Arcing projectile"},
        {"id": "weapon_05", "type": "persistent_aura", "name": "Aura", "base_dmg": 5, "max_level": 8, "description": "Constant damage zone"},
        {"id": "weapon_06", "type": "ground_pool", "name": "Ground Pool", "base_dmg": 18, "max_level": 8, "description": "Random damage zone"},
        {"id": "weapon_07", "type": "orbiting", "name": "Orbiting", "base_dmg": 10, "max_level": 8, "description": "Orbits player"},
        {"id": "weapon_08", "type": "random_strike", "name": "Strike", "base_dmg": 30, "max_level": 8, "description": "Random explosion"},
        {"id": "weapon_09", "type": "bouncing", "name": "Bouncing", "base_dmg": 14, "max_level": 8, "description": "Bounces off edges"},
        {"id": "weapon_10", "type": "freeze_beam", "name": "Freeze Beam", "base_dmg": 0, "max_level": 8, "description": "Freezes enemies"}
    ]
    for w in w_data:
        weapons[w["id"]] = w
        
    var p_data = [
        {"id": "passive_01", "name": "Max HP", "stat": "max_hp", "max_level": 5, "description": "+10% max HP"},
        {"id": "passive_02", "name": "Cooldown", "stat": "cooldown_reduction", "max_level": 5, "description": "-8% cooldown"},
        {"id": "passive_03", "name": "Proj Speed", "stat": "projectile_speed", "max_level": 5, "description": "+10% proj speed"},
        {"id": "passive_04", "name": "Area", "stat": "area", "max_level": 5, "description": "+10% AoE"},
        {"id": "passive_05", "name": "Regen", "stat": "hp_regen", "max_level": 5, "description": "+0.3 HP/s"},
        {"id": "passive_06", "name": "Magnet", "stat": "xp_radius", "max_level": 5, "description": "+20% pickup"},
        {"id": "passive_07", "name": "Duration", "stat": "effect_duration", "max_level": 5, "description": "+10% duration"},
        {"id": "passive_08", "name": "Luck", "stat": "luck", "max_level": 5, "description": "+10% luck"},
        {"id": "passive_09", "name": "Armor", "stat": "armor", "max_level": 5, "description": "+1 armor"},
        {"id": "passive_10", "name": "Damage", "stat": "damage_bonus", "max_level": 5, "description": "+5% damage"}
    ]
    for p in p_data:
        passives[p["id"]] = p
