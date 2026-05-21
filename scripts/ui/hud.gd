extends Control

@onready var health_container: HBoxContainer = $HealthContainer
@onready var stamina_bar: ProgressBar = $Bars/StaminaBar
@onready var hunger_bar: ProgressBar = $Bars/HungerBar
@onready var thirst_bar: ProgressBar = $Bars/ThirstBar
@onready var time_label: Label = $TimeLabel
@onready var biome_label: Label = $BiomeLabel

@export var heart_full: Texture2D
@export var heart_empty: Texture2D

func _ready() -> void:
    UIManager.register_ui(self, $"../PauseMenu", $"../InventoryUI", $"../CraftingUI", $"../DeathScreen")

    await get_tree().process_frame
    var player = get_tree().get_first_node_in_group("player")
    if player and player.stats:
        player.stats.health_changed.connect(update_health)
        player.stats.stamina_changed.connect(update_stamina)
        player.stats.hunger_changed.connect(update_hunger)
        player.stats.thirst_changed.connect(update_thirst)

        update_health(player.stats.current_health, player.stats.max_health)
        update_stamina(player.stats.current_stamina, player.stats.max_stamina)
        update_hunger(player.stats.current_hunger, player.stats.max_hunger)
        update_thirst(player.stats.current_thirst, player.stats.max_thirst)

func _process(_delta: float) -> void:
    var hour := int(GameManager.current_time)
    var minute := int((GameManager.current_time - hour) * 60)
    time_label.text = "%02d:%02d" % [hour, minute]

    var period := GameManager.get_time_period()
    match period:
        "day": time_label.modulate = Color.YELLOW
        "dusk": time_label.modulate = Color.ORANGE
        "night": time_label.modulate = Color.BLUE
        "dawn": time_label.modulate = Color.PINK

    biome_label.text = GameManager.current_biome.capitalize()

func update_health(current: int, maximum: int) -> void:
    for child in health_container.get_children():
        child.queue_free()

    for i in range(maximum):
        var heart := TextureRect.new()
        heart.texture = heart_full if i < current else heart_empty
        heart.custom_minimum_size = Vector2(24, 24)
        heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
        health_container.add_child(heart)

func update_stamina(current: float, maximum: float) -> void:
    stamina_bar.value = (current / maximum) * 100.0
    stamina_bar.get_theme_stylebox("fill").bg_color = Color(0.2, 0.8, 0.3) if current > 20.0 else Color(0.9, 0.2, 0.2)

func update_hunger(current: float, maximum: float) -> void:
    hunger_bar.value = (current / maximum) * 100.0
    hunger_bar.get_theme_stylebox("fill").bg_color = Color(0.9, 0.5, 0.1)

func update_thirst(current: float, maximum: float) -> void:
    thirst_bar.value = (current / maximum) * 100.0
    thirst_bar.get_theme_stylebox("fill").bg_color = Color(0.2, 0.5, 0.9)

func update_time(time_string: String, period: String) -> void:
    pass
