extends Node

@export var proj_scene: PackedScene
var pool_size: int = 1000
var pool: Array[Node] = []

func _ready() -> void:
    proj_scene = preload("res://scenes/projectile.tscn")
    for i in range(pool_size):
        var proj = proj_scene.instantiate()
        proj.is_active = false
        proj.visible = false
        if proj.has_node("CollisionShape2D"):
            proj.get_node("CollisionShape2D").set_deferred("disabled", true)
        proj.global_position = Vector2(-9999, -9999)
        proj.set_meta("pool", self)
        add_child(proj)
        pool.append(proj)

func spawn_projectile(pos: Vector2, vel: Vector2, dmg: float, pierce: int = 1, fixed_lifetime: float = 2.0, is_lob: bool = false, is_bouncing: bool = false) -> void:
    if pool.is_empty():
        return
            
    var proj = pool.pop_back()
    proj.activate(pos, vel, dmg, pierce, fixed_lifetime, is_lob, is_bouncing)

func return_projectile(proj: Node) -> void:
    proj.deactivate()
    pool.append(proj)
