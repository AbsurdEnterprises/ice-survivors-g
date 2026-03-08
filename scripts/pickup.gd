extends Area2D
class_name ItemPickup

var pickup_type: String = "gold"

func _ready() -> void:
    match pickup_type:
        "gold": $ColorRect.color = Color(1, 0.84, 0) # Gold
        "heal": $ColorRect.color = Color(0.1, 0.8, 0.1) # Green
        "magnet": $ColorRect.color = Color(0, 0, 1) # Blue
        "nuke": $ColorRect.color = Color(1, 0, 0) # Red
