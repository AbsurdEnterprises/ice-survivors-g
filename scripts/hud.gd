extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel

func update_hp(current: float, maximum: float) -> void:
    hp_bar.max_value = maximum
    hp_bar.value = current
    hp_label.text = str(floor(current)) + " / " + str(floor(maximum))
