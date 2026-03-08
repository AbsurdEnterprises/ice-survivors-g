extends CanvasLayer

@onready var container = $VBoxContainer

var options = []
var player: Node2D

func _ready():
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    visible = false
    # create 4 buttons dynamically
    for i in range(4):
        var btn = Button.new()
        btn.custom_minimum_size = Vector2(400, 100)
        btn.pressed.connect(Callable(self, "_on_option_selected").bind(i))
        container.add_child(btn)

func show_level_up(p_player: Node2D, num_options: int) -> void:
    player = p_player
    get_tree().paused = true
    visible = true
    roll_options(num_options)
    update_ui()

func roll_options(count: int) -> void:
    options.clear()
    var pool = []
    
    var luck = 0.0 # From player eventually
    
    for w_id in GameData.weapons.keys():
        var w = GameData.weapons[w_id]
        var w_type = "weapon"
        var weight = 10.0 + (luck * 2.0)
        # TODO check player inventory for upgrade weight
        pool.append({"id": w_id, "type": w_type, "data": w, "weight": weight})
        
    for p_id in GameData.passives.keys():
        var p = GameData.passives[p_id]
        var p_type = "passive"
        var weight = 10.0 + (luck * 2.0)
        if p_id == "passive_05" or p_id == "passive_06":
            weight = 5.0 + (luck * 3.0)
        pool.append({"id": p_id, "type": p_type, "data": p, "weight": weight})
        
    # Weighted draw without replacement
    for i in range(count):
        if pool.is_empty(): break
        var total = 0.0
        for item in pool: total += item["weight"]
        var roll = randf() * total
        var current = 0.0
        var selected_idx = 0
        for j in range(pool.size()):
            current += pool[j]["weight"]
            if roll <= current:
                selected_idx = j
                break
        options.append(pool[selected_idx])
        pool.remove_at(selected_idx)

func update_ui() -> void:
    for i in range(4):
        var btn = container.get_child(i)
        if i < options.size():
            btn.visible = true
            var opt = options[i]
            btn.text = opt["data"]["name"] + "\n" + opt["data"]["description"]
        else:
            btn.visible = false

func _on_option_selected(index: int) -> void:
    if index < options.size():
        var opt = options[index]
        print("Selected: ", opt["id"])
        # TODO: Add to player inventory
    close()

func close() -> void:
    visible = false
    get_tree().paused = false
