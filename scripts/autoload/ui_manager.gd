extends Node

@onready var hud: Control
@onready var pause_menu: Control
@onready var inventory_ui: Control
@onready var crafting_ui: Control
@onready var death_screen: Control

var is_inventory_open: bool = false
var is_crafting_open: bool = false

func _ready() -> void:
    pass

func register_ui(hud_node: Control, pause: Control, inv: Control, craft: Control, death: Control) -> void:
    hud = hud_node
    pause_menu = pause
    inventory_ui = inv
    crafting_ui = craft
    death_screen = death

func show_hud() -> void:
    if hud: hud.show()

func hide_hud() -> void:
    if hud: hud.hide()

func show_pause_menu() -> void:
    if pause_menu: pause_menu.show()

func hide_pause_menu() -> void:
    if pause_menu: pause_menu.hide()

func toggle_inventory() -> void:
    is_inventory_open = !is_inventory_open
    if inventory_ui:
        inventory_ui.visible = is_inventory_open
    if is_inventory_open:
        is_crafting_open = false
        if crafting_ui: crafting_ui.hide()

func toggle_crafting() -> void:
    is_crafting_open = !is_crafting_open
    if crafting_ui:
        crafting_ui.visible = is_crafting_open
    if is_crafting_open:
        is_inventory_open = false
        if inventory_ui: inventory_ui.hide()

func show_death_screen() -> void:
    if death_screen: death_screen.show()
    if hud: hud.hide()

func hide_death_screen() -> void:
    if death_screen: death_screen.hide()
    if hud: hud.show()

func update_hud_health(current: int, maximum: int) -> void:
    if hud and hud.has_method("update_health"):
        hud.update_health(current, maximum)

func update_hud_stamina(current: float, maximum: float) -> void:
    if hud and hud.has_method("update_stamina"):
        hud.update_stamina(current, maximum)

func update_hud_hunger(current: float, maximum: float) -> void:
    if hud and hud.has_method("update_hunger"):
        hud.update_hunger(current, maximum)

func update_hud_thirst(current: float, maximum: float) -> void:
    if hud and hud.has_method("update_thirst"):
        hud.update_thirst(current, maximum)

func update_hud_time(time_string: String, period: String) -> void:
    if hud and hud.has_method("update_time"):
        hud.update_time(time_string, period)
