extends Control

@onready var shop_panel = $ShopPanel
@onready var gold_label = $VBoxContainer/GoldLabel
@onready var upgrade_container = $ShopPanel/VBoxContainer/ScrollContainer/ItemList

func _ready() -> void:
    get_tree().paused = false
    shop_panel.visible = false
    update_gold_display()
    
    $VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
    $VBoxContainer/ShopButton.pressed.connect(_on_shop_pressed)
    $ShopPanel/VBoxContainer/CloseButton.pressed.connect(_on_close_shop)

func update_gold_display() -> void:
    gold_label.text = "Gold: " + str(SaveManager.save_data["gold"])

func _on_play_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_shop_pressed() -> void:
    shop_panel.visible = true
    populate_shop()

func _on_close_shop() -> void:
    shop_panel.visible = false

func populate_shop() -> void:
    for child in upgrade_container.get_children():
        child.queue_free()
        
    for m_id in GameData.meta_data_dict:
        var data = GameData.meta_data_dict[m_id]
        var current_level = 0
        if SaveManager.save_data["meta_upgrades"].has(m_id):
            current_level = SaveManager.save_data["meta_upgrades"][m_id]
            
        var btn = Button.new()
        btn.custom_minimum_size = Vector2(400, 60)
        
        if current_level >= data["max_level"]:
            btn.text = data["name"] + " (MAX) - " + data["desc"]
            btn.disabled = true
        else:
            var cost = data["base_cost"] * (1 + current_level)
            btn.text = data["name"] + " Lv " + str(current_level) + " -> " + str(cost) + "G\n" + data["desc"]
            btn.pressed.connect(func():
                if SaveManager.buy_upgrade(m_id, cost):
                    update_gold_display()
                    populate_shop()
            )
        upgrade_container.add_child(btn)
