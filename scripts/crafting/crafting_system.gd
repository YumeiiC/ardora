extends Node

signal recipe_crafted(recipe_id: String, result: Dictionary)
signal craft_failed(recipe_id: String, reason: String)

func craft(recipe_id: String) -> bool:
    recipe_crafted.emit(recipe_id, {})
    return true
