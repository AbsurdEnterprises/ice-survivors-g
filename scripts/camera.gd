extends Camera2D

@export var target_node: NodePath
var target: Node2D
var follow_weight: float = 0.1

func _ready() -> void:
	if not target_node.is_empty():
		target = get_node(target_node)
	elif get_tree().has_group("player"):
		target = get_tree().get_nodes_in_group("player")[0]

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, follow_weight)
