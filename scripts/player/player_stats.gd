class_name PlayerStats
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

const HUNGER_DRAIN := 0.033
const THIRST_DRAIN := 0.055
const STAMINA_REGEN := 2.0
const HEALTH_REGEN := 0.5

func _process(delta: float) -> void:
    _drain_needs(delta)
    _regen_stamina(delta)
    _regen_health(delta)

func _drain_needs(delta: float) -> void:
    current_hunger = max(0.0, current_hunger - HUNGER_DRAIN * delta)
    current_thirst = max(0.0, current_thirst - THIRST_DRAIN * delta)

    hunger_changed.emit(current_hunger, max_hunger)
    thirst_changed.emit(current_thirst, max_thirst)

    if current_hunger <= 0.0 or current_thirst <= 0.0:
        _take_damage(1)

func _regen_stamina(delta: float) -> void:
    if current_stamina < max_stamina and current_hunger > 20.0 and current_thirst > 20.0:
        current_stamina = min(max_stamina, current_stamina + STAMINA_REGEN * delta)
        stamina_changed.emit(current_stamina, max_stamina)

func _regen_health(delta: float) -> void:
    if current_health < max_health and current_hunger > 80.0 and current_thirst > 80.0 and current_stamina > 50.0:
        current_health = min(max_health, current_health + int(HEALTH_REGEN * delta))
        health_changed.emit(current_health, max_health)

func consume_stamina(amount: float) -> bool:
    if current_stamina >= amount:
        current_stamina -= amount
        stamina_changed.emit(current_stamina, max_stamina)
        return true
    return false

func heal(amount: int) -> void:
    current_health = min(max_health, current_health + amount)
    health_changed.emit(current_health, max_health)

func consume_food(hunger_value: float, health_bonus: int = 0) -> void:
    current_hunger = min(max_hunger, current_hunger + hunger_value)
    hunger_changed.emit(current_hunger, max_hunger)
    if health_bonus > 0:
        heal(health_bonus)

func consume_water(thirst_value: float) -> void:
    current_thirst = min(max_thirst, current_thirst + thirst_value)
    thirst_changed.emit(current_thirst, max_thirst)

func _take_damage(amount: int) -> void:
    current_health -= amount
    health_changed.emit(current_health, max_health)
    if current_health <= 0:
        player_died.emit()
