extends CanvasLayer

@onready var time_label = $Panel/VBoxContainer/TimeLabel
@onready var kill_label = $Panel/VBoxContainer/KillLabel
@onready var gold_label = $Panel/VBoxContainer/GoldLabel
@onready var button = $Panel/VBoxContainer/MainMenuButton

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    button.pressed.connect(_on_main_menu_pressed)

func show_summary(t_elapsed: float, kills: int, gold: int) -> void:
    var t = int(t_elapsed)
    time_label.text = "Time Survived: %02d:%02d" % [t / 60, t % 60]
    kill_label.text = "Kills: " + str(kills)
    gold_label.text = "Gold Earned: " + str(gold)

func _on_main_menu_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
    queue_free()
