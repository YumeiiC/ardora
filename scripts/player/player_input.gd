extends Node

func get_movement_direction() -> Vector2:
    var dir := Vector2.ZERO
    dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    return dir.normalized() if dir.length() > 0.1 else Vector2.ZERO

func is_sprinting() -> bool:
    return Input.is_action_pressed("sprint")
