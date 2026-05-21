class_name Inventory
extends Node

signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal inventory_changed

const MAX_SLOTS := 30

var items: Array[Dictionary] = []
var equipped_weapon: String = ""
var equipped_tool: String = ""

func _ready() -> void:
    if GameManager.player_data.has("inventory"):
        _deserialize(GameManager.player_data.inventory)

func add_item(item_id: String, count: int = 1) -> bool:
    var item_data := _get_item_data(item_id)
    if item_data.is_empty():
        push_error("Item not found: " + item_id)
        return false

    var max_stack: int = item_data.get("max_stack", 99)
    var remaining := count

    for i in range(items.size()):
        if items[i].id == item_id and items[i].count < max_stack:
            var can_add := min(remaining, max_stack - items[i].count)
            items[i].count += can_add
            remaining -= can_add
            if remaining <= 0:
                item_added.emit(item_id, count)
                inventory_changed.emit()
                return true

    while remaining > 0 and items.size() < MAX_SLOTS:
        var stack_count := min(remaining, max_stack)
        items.append({"id": item_id, "count": stack_count})
        remaining -= stack_count

    if remaining > 0:
        push_warning("Inventory full! Dropped " + str(remaining) + " " + item_id)

    item_added.emit(item_id, count - remaining)
    inventory_changed.emit()
    return remaining == 0

func remove_item(item_id: String, count: int = 1) -> bool:
    var remaining := count

    for i in range(items.size() - 1, -1, -1):
        if items[i].id == item_id:
            if items[i].count <= remaining:
                remaining -= items[i].count
                items.remove_at(i)
            else:
                items[i].count -= remaining
                remaining = 0

            if remaining <= 0:
                item_removed.emit(item_id, count)
                inventory_changed.emit()
                return true

    return false

func has_item(item_id: String, count: int = 1) -> bool:
    var total := 0
    for item in items:
        if item.id == item_id:
            total += item.count
    return total >= count

func get_item_count(item_id: String) -> int:
    var total := 0
    for item in items:
        if item.id == item_id:
            total += item.count
    return total

func equip_item(item_id: String) -> bool:
    var item_data := _get_item_data(item_id)
    if item_data.is_empty():
        return false

    var item_type: String = item_data.get("type", "")
    match item_type:
        "weapon":
            equipped_weapon = item_id
        "tool":
            equipped_tool = item_id
        _:
            return false

    inventory_changed.emit()
    return true

func drop_random_items(percentage: float) -> void:
    var drop_count := int(items.size() * percentage)
    var indices_to_remove: Array[int] = []

    while indices_to_remove.size() < drop_count and items.size() > 0:
        var idx := randi() % items.size()
        if not indices_to_remove.has(idx):
            indices_to_remove.append(idx)

    indices_to_remove.sort()
    indices_to_remove.reverse()

    for idx in indices_to_remove:
        items.remove_at(idx)

    inventory_changed.emit()

func serialize() -> Dictionary:
    return {
        "items": items.duplicate(),
        "equipped_weapon": equipped_weapon,
        "equipped_tool": equipped_tool
    }

func _deserialize(data: Dictionary) -> void:
    items = data.get("items", [])
    equipped_weapon = data.get("equipped_weapon", "")
    equipped_tool = data.get("equipped_tool", "")

func _get_item_data(item_id: String) -> Dictionary:
    var file := FileAccess.open("res://data/items.json", FileAccess.READ)
    if file == null:
        return {}

    var json := JSON.new()
    json.parse(file.get_as_text())
    file.close()

    var items_db: Array = json.data.get("items", [])
    for item in items_db:
        if item.get("id", "") == item_id:
            return item

    return {}
