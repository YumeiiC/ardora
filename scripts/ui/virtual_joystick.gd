extends Control

signal joystick_output(direction: Vector2)

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

var is_pressed: bool = false
var touch_index: int = -1
var max_distance: float = 50.0
var base_position: Vector2

func _ready() -> void:
    base_position = base.position + base.size / 2
    knob.position = base_position - knob.size / 2
    add_to_group("virtual_joystick")

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _is_inside_base(event.position):
            is_pressed = true
            touch_index = event.index
            _update_knob(event.position)
        elif not event.pressed and event.index == touch_index:
            is_pressed = false
            touch_index = -1
            _reset_knob()
            joystick_output.emit(Vector2.ZERO)

    if event is InputEventScreenDrag and event.index == touch_index:
        _update_knob(event.position)

func _is_inside_base(pos: Vector2) -> bool:
    var base_rect := base.get_global_rect()
    return base_rect.has_point(pos)

func _update_knob(pos: Vector2) -> void:
    var direction := pos - base_position
    var distance := min(direction.length(), max_distance)
    direction = direction.normalized() * distance

    knob.position = base_position + direction - knob.size / 2

    var output := direction / max_distance
    joystick_output.emit(output)

func _reset_knob() -> void:
    var tween := create_tween()
    tween.tween_property(knob, "position", base_position - knob.size / 2, 0.1)
