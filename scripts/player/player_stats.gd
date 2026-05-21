extends Node

signal health_changed(current: int, maximum: int)
signal stamina_changed(current: float, maximum: float)
signal hunger_changed(current: float, maximum: float)
signal thirst_changed(current: float, maximum: float)
signal player_died

@export var max_health: int = 5
@export var max_stamina: float = 100.0
@export var max_hunger: float = 100.0
@export var max_thirst: float = 100.0

var current_health: int = 5
var current_stamina: float = 100.0
var current_hunger: float = 100.0
var current_thirst: float = 100.0

func _process(delta: float) -> void:
    current_hunger = max(0.0, current_hunger - 0.033 * delta)
    current_thirst = max(0.0, current_thirst - 0.055 * delta)
    
    hunger_changed.emit(current_hunger, max_hunger)
    thirst_changed.emit(current_thirst, max_thirst)

func consume_stamina(amount: float) -> bool:
    if current_stamina >= amount:
        current_stamina -= amount
        stamina_changed.emit(current_stamina, max_stamina)
        return true
    return false
