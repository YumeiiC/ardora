extends Node

const SAVE_PATH := "user://saves/"
const SAVE_EXTENSION := ".ardora"

signal game_saved(save_name: String)
signal game_loaded(save_name: String)

func _ready() -> void:
    _ensure_save_dir()

func _ensure_save_dir() -> void:
    var dir := DirAccess.open("user://")
    if not dir.dir_exists("saves"):
        dir.make_dir("saves")

func save_game(save_name: String) -> bool:
    var save_data := {
        "version": "0.1.0",
        "timestamp": Time.get_unix_time_from_system(),
        "world_seed": GameManager.world_seed,
        "current_time": GameManager.current_time,
        "player": _serialize_player(),
        "inventory": _serialize_inventory(),
        "world_chunks": _serialize_chunks()
    }

    var file := FileAccess.open(SAVE_PATH + save_name + SAVE_EXTENSION, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open save file: " + save_name)
        return false

    file.store_string(JSON.stringify(save_data))
    file.close()

    game_saved.emit(save_name)
    print("Game saved: " + save_name)
    return true

func load_game(save_name: String) -> bool:
    var file := FileAccess.open(SAVE_PATH + save_name + SAVE_EXTENSION, FileAccess.READ)
    if file == null:
        push_error("Save file not found: " + save_name)
        return false

    var json := JSON.new()
    var error := json.parse(file.get_as_text())
    file.close()

    if error != OK:
        push_error("Failed to parse save file")
        return false

    var save_data: Dictionary = json.data

    GameManager.world_seed = save_data.get("world_seed", 0)
    GameManager.current_time = save_data.get("current_time", 6.0)

    _deserialize_player(save_data.get("player", {}))
    _deserialize_inventory(save_data.get("inventory", {}))
    _deserialize_chunks(save_data.get("world_chunks", {}))

    game_loaded.emit(save_name)
    print("Game loaded: " + save_name)
    return true

func get_save_list() -> Array[String]:
    var saves: Array[String] = []
    var dir := DirAccess.open(SAVE_PATH)
    if dir == null:
        return saves

    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        if file_name.ends_with(SAVE_EXTENSION):
            saves.append(file_name.trim_suffix(SAVE_EXTENSION))
        file_name = dir.get_next()

    return saves

func delete_save(save_name: String) -> bool:
    var dir := DirAccess.open(SAVE_PATH)
    if dir == null:
        return false
    return dir.remove(SAVE_PATH + save_name + SAVE_EXTENSION) == OK

func _serialize_player() -> Dictionary:
    var player = get_tree().get_first_node_in_group("player")
    if player == null:
        return {}

    return {
        "position": {
            "x": player.global_position.x,
            "y": player.global_position.y
        },
        "stats": {
            "health": player.stats.current_health,
            "stamina": player.stats.current_stamina,
            "hunger": player.stats.current_hunger,
            "thirst": player.stats.current_thirst
        }
    }

func _serialize_inventory() -> Dictionary:
    var player = get_tree().get_first_node_in_group("player")
    if player == null or player.inventory == null:
        return {"items": []}

    return player.inventory.serialize()

func _serialize_chunks() -> Dictionary:
    var world = get_tree().get_first_node_in_group("world")
    if world == null or world.chunk_manager == null:
        return {}

    return world.chunk_manager.serialize_modified_chunks()

func _deserialize_player(data: Dictionary) -> void:
    GameManager.player_data = data

func _deserialize_inventory(data: Dictionary) -> void:
    GameManager.player_data["inventory"] = data

func _deserialize_chunks(data: Dictionary) -> void:
    GameManager.player_data["chunks"] = data
