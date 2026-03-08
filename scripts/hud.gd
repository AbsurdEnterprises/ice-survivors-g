extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel

func update_hp(current: float, maximum: float) -> void:
    hp_bar.max_value = maximum
    hp_bar.value = current
    hp_label.text = str(floor(current)) + " / " + str(floor(maximum))

func update_xp(current: float, required: float) -> void:
    xp_bar.max_value = required
    xp_bar.value = current

func update_level(lvl: int) -> void:
    level_label.text = "Lv " + str(lvl)
