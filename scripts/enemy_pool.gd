extends Node

@export var enemy_scene: PackedScene
var pool_size: int = 500
var pool: Array[Node] = []
var active_enemies: int = 0

func _ready() -> void:
    enemy_scene = preload("res://scenes/enemy.tscn")
    for i in range(pool_size):
        var enemy = enemy_scene.instantiate()
        enemy.is_active = false
        enemy.visible = false
        enemy.set_physics_process(false)
        if enemy.has_node("CollisionShape2D"):
            enemy.get_node("CollisionShape2D").set_deferred("disabled", true)
        enemy.global_position = Vector2(-9999, -9999)
        # Store reference to the pool so it can return itself
        enemy.set_meta("pool", self)
        add_child(enemy)
        pool.append(enemy)

func get_enemy() -> Node:
    if pool.is_empty():
        return null
    var enemy = pool.pop_back()
    active_enemies += 1
    return enemy

func return_enemy(enemy: Node) -> void:
    enemy.deactivate()
    pool.append(enemy)
    active_enemies -= 1
