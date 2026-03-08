extends Camera2D

@export var target_node: NodePath
var target: Node2D
var follow_weight: float = 0.1
var is_locked: bool = false
var shake_intensity: float = 0.0

func apply_shake(amt: float) -> void:
    shake_intensity = max(shake_intensity, amt)

func _process(delta: float) -> void:
    if shake_intensity > 0:
        offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
        shake_intensity = lerp(shake_intensity, 0.0, 10.0 * delta)
        if shake_intensity < 0.1:
            shake_intensity = 0.0
            offset = Vector2.ZERO

func _ready() -> void:
	if not target_node.is_empty():
		target = get_node(target_node)
	elif get_tree().has_group("player"):
		target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target) and not is_locked:
		global_position = global_position.lerp(target.global_position, follow_weight)
