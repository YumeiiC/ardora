class_name Player
extends CharacterBody2D

const SPEED := 100.0
const SPRINT_SPEED := 160.0

var velocity_input: Vector2 = Vector2.ZERO

func _ready() -> void:
    add_to_group("player")

func _physics_process(delta: float) -> void:
    var input_dir := Vector2.ZERO
    input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    input_dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    
    if input_dir.length() > 0.1:
        velocity = input_dir.normalized() * SPEED
    else:
        velocity = Vector2.ZERO
    
    move_and_slide()
