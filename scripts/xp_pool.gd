extends Node

@export var gem_scene: PackedScene
var pool_size: int = 300
var pool: Array[Node] = []
var active_gems: Array[Node] = []

func _ready() -> void:
    gem_scene = preload("res://scenes/xp_gem.tscn")
    for i in range(pool_size):
        var gem = gem_scene.instantiate()
        gem.is_active = false
        gem.visible = false
        if gem.has_node("CollisionShape2D"):
            gem.get_node("CollisionShape2D").set_deferred("disabled", true)
        gem.global_position = Vector2(-9999, -9999)
        gem.set_meta("pool", self)
        add_child(gem)
        pool.append(gem)

func spawn_gem(pos: Vector2, val: int) -> void:
    if pool.is_empty():
        merge_gems()
        if pool.is_empty():
            return
            
    var gem = pool.pop_back()
    gem.activate(pos, val)
    active_gems.append(gem)

func return_gem(gem: Node) -> void:
    gem.deactivate()
    active_gems.erase(gem)
    pool.append(gem)

func merge_gems() -> void:
    # Phase 4 specifies merging if > 200 gems. We use 300 capacity so we merge if we run out.
    if active_gems.size() < 2: return
    
    var total_val = 0
    var center = Vector2.ZERO
    for g in active_gems:
        total_val += g.xp_value
        center += g.global_position
        
    center /= active_gems.size()
    
    # Deactivate all active gems manually to repool
    for i in range(active_gems.size() - 1, -1, -1):
        var g = active_gems[i]
        g.is_active = false
        g.visible = false
        g.get_node("CollisionShape2D").set_deferred("disabled", true)
        g.global_position = Vector2(-9999, -9999)
        pool.append(g)
        
    active_gems.clear()
    
    var mega_gem = pool.pop_back()
    mega_gem.activate(center, total_val)
    active_gems.append(mega_gem)
