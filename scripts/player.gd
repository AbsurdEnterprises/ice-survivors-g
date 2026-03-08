extends CharacterBody2D

var base_speed: float = 135.0 # default from char_01
var max_hp: float = 120.0
var current_hp: float = 120.0
var xp_radius: float = 64.0

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * base_speed
	move_and_slide()
	global_position.y = clamp(global_position.y, -300.0, 300.0)
