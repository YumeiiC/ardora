extends Node

var world_seed: int = 12345
var current_time: float = 6.0
var is_paused: bool = false

func _ready() -> void:
    randomize()
    world_seed = randi() % 999999

func get_time_period() -> String:
    if current_time >= 6.0 and current_time < 18.0:
        return "day"
    elif current_time >= 18.0 and current_time < 20.0:
        return "dusk"
    elif current_time >= 20.0 or current_time < 4.0:
        return "night"
    else:
        return "dawn"

func is_night() -> bool:
    return get_time_period() == "night"
