extends Control

signal joystick_output(direction: Vector2)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch or event is InputEventScreenDrag:
        joystick_output.emit(Vector2.ZERO)
