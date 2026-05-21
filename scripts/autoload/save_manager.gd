extends Node

signal game_saved(save_name: String)
signal game_loaded(save_name: String)

func save_game(save_name: String) -> bool:
    print("Game saved: " + save_name)
    game_saved.emit(save_name)
    return true

func load_game(save_name: String) -> bool:
    print("Game loaded: " + save_name)
    game_loaded.emit(save_name)
    return true
