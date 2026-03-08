extends Node

var save_path = "user://save.json"
var save_data = {
    "gold": 0,
    "meta_upgrades": {}
}

func _ready() -> void:
    load_game()

func save_game() -> void:
    var file = FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(save_data))
        file.close()

func load_game() -> void:
    if FileAccess.file_exists(save_path):
        var file = FileAccess.open(save_path, FileAccess.READ)
        if file:
            var json_str = file.get_as_text()
            file.close()
            var json = JSON.new()
            var err = json.parse(json_str)
            if err == OK:
                # Merge loaded data with defaults in case of new fields
                var loaded = json.data
                if loaded.has("gold"): save_data["gold"] = loaded["gold"]
                if loaded.has("meta_upgrades"): save_data["meta_upgrades"] = loaded["meta_upgrades"]

func end_run() -> void:
    save_data["gold"] += GameData.run_gold
    GameData.run_gold = 0
    save_game()

func buy_upgrade(meta_id: String, cost: int) -> bool:
    if save_data["gold"] >= cost:
        save_data["gold"] -= cost
        if not save_data["meta_upgrades"].has(meta_id):
            save_data["meta_upgrades"][meta_id] = 1
        else:
            save_data["meta_upgrades"][meta_id] += 1
        save_game()
        return true
    return false
