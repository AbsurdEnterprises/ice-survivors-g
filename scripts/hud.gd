extends CanvasLayer

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPBar/HPLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel
@onready var boss_hp_bar: ProgressBar = $BossHPBar
@onready var time_label: Label = $TimeLabel
@onready var kill_label: Label = $KillLabel

func _process(delta: float) -> void:
	kill_label.text = "Kills: " + str(GameData.run_kills)
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner:
		var t = int(spawner.time_elapsed)
		var m = t / 60
		var s = t % 60
		@warning_ignore("integer_division")
		time_label.text = "%02d:%02d" % [m, s]

func update_hp(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	hp_label.text = str(floor(current)) + " / " + str(floor(maximum))

func update_xp(current: float, required: float) -> void:
	xp_bar.max_value = required
	xp_bar.value = current

func update_level(lvl: int) -> void:
	level_label.text = "Lv " + str(lvl)

func show_boss_hp(current: float, maximum: float) -> void:
	boss_hp_bar.max_value = maximum
	boss_hp_bar.value = current
	boss_hp_bar.visible = true

func update_boss_hp(current: float, maximum: float) -> void:
	boss_hp_bar.max_value = maximum
	boss_hp_bar.value = current

func hide_boss_hp() -> void:
	boss_hp_bar.visible = false
