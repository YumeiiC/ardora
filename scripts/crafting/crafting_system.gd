class_name CraftingSystem
extends Node

signal recipe_crafted(recipe_id: String, result: Dictionary)
signal craft_failed(recipe_id: String, reason: String)

var recipes: Array[Dictionary] = []
var available_stations: Array[String] = ["hand"]

func _ready() -> void:
    _load_recipes()

func _load_recipes() -> void:
    var data := JsonLoader.load_json("res://data/recipes.json")
    recipes = data.get("recipes", [])

func add_station(station: String) -> void:
    if not available_stations.has(station):
        available_stations.append(station)

func get_available_recipes() -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    var player = get_tree().get_first_node_in_group("player")

    if player == null or player.inventory == null:
        return available

    for recipe in recipes:
        if available_stations.has(recipe.station):
            if _has_ingredients(player.inventory, recipe.ingredients):
                available.append(recipe)

    return available

func craft(recipe_id: String) -> bool:
    var recipe := _get_recipe(recipe_id)
    if recipe.is_empty():
        craft_failed.emit(recipe_id, "Recipe not found")
        return false

    if not available_stations.has(recipe.station):
        craft_failed.emit(recipe_id, "Station not available")
        return false

    var player = get_tree().get_first_node_in_group("player")
    if player == null or player.inventory == null:
        craft_failed.emit(recipe_id, "No player inventory")
        return false

    if not _has_ingredients(player.inventory, recipe.ingredients):
        craft_failed.emit(recipe_id, "Missing ingredients")
        return false

    # Consume ingredients
    for ingredient in recipe.ingredients:
        player.inventory.remove_item(ingredient.item, ingredient.count)

    # Add result
    player.inventory.add_item(recipe.result.item, recipe.result.count)

    AudioManager.play_sfx("craft")
    recipe_crafted.emit(recipe_id, recipe.result)
    return true

func _get_recipe(recipe_id: String) -> Dictionary:
    for recipe in recipes:
        if recipe.id == recipe_id:
            return recipe
    return {}

func _has_ingredients(inventory: Node, ingredients: Array) -> bool:
    for ingredient in ingredients:
        if not inventory.has_item(ingredient.item, ingredient.count):
            return false
    return true
