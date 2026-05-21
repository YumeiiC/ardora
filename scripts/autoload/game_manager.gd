extends Node

const SAVE_PATH := "user://saves/"
const TILE_SIZE := 16
const CHUNK_SIZE := 16
const WORLD_SEED_MAX := 999999

var player_data: Dictionary = {}
var world_seed: int = 0
var current_time: float = 6.0
var is_paused: bool = false
var current_biome: String = "forest"

func _ready() -> void:
    randomize()
    world_seed = randi() % WORLD_SEED_MAX
    _ensure_save_dir()

func _ensure_save_dir() -> void:
    var dir := DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")

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

func get_day_night_modifier() -> float:
    match get_time_period():
        "day": return 1.0
        "dusk": return 0.7
        "night": return 0.3
        "dawn": return 0.7
    return 1.0

func pause_game() -> void:
    is_paused = true
    get_tree().paused = true
    UIManager.show_pause_menu()

func resume_game() -> void:
    is_paused = false
    get_tree().paused = false
    UIManager.hide_pause_menu()

func quit_to_menu() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/screens/MainMenu.tscn")

func new_game() -> void:
    player_data = {}
    current_time = 6.0
    world_seed = randi() % WORLD_SEED_MAX
    get_tree().change_scene_to_file("res://scenes/screens/GameScreen.tscn")

func load_game(save_name: String) -> void:
    SaveManager.load_game(save_name)
    get_tree().change_scene_to_file("res://scenes/screens/GameScreen.tscn")
