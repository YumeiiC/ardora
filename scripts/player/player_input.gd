class_name PlayerInput
extends Node

@onready var player: CharacterBody2D = get_parent()
@onready var virtual_joystick: Control

var joystick_direction: Vector2 = Vector2.ZERO
var is_joystick_active: bool = false

func _ready() -> void:
    virtual_joystick = get_tree().get_first_node_in_group("virtual_joystick")
    if virtual_joystick:
        virtual_joystick.joystick_output.connect(_on_joystick_moved)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("inventory"):
        UIManager.toggle_inventory()

    if event.is_action_pressed("interact"):
        player.interact()

    if event.is_action_pressed("attack"):
        player.combat.attack()

    if event.is_action_pressed("pause"):
        if GameManager.is_paused:
            GameManager.resume_game()
        else:
            GameManager.pause_game()

func get_movement_direction() -> Vector2:
    if is_joystick_active:
        return joystick_direction

    var dir := Vector2.ZERO
    dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
    dir.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

    return dir.normalized() if dir.length() > 0.1 else Vector2.ZERO

func is_sprinting() -> bool:
    return Input.is_action_pressed("sprint") or _is_sprint_button_pressed()

func _is_sprint_button_pressed() -> bool:
    var sprint_btn = get_tree().get_first_node_in_group("sprint_button")
    if sprint_btn:
        return sprint_btn.is_pressed
    return false

func _on_joystick_moved(direction: Vector2) -> void:
    joystick_direction = direction
    is_joystick_active = direction.length() > 0.1
