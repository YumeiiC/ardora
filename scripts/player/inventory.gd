extends Node

signal item_added(item_id: String, count: int)
signal item_removed(item_id: String, count: int)
signal inventory_changed

var items: Array[Dictionary] = []

func add_item(item_id: String, count: int = 1) -> bool:
    items.append({"id": item_id, "count": count})
    item_added.emit(item_id, count)
    inventory_changed.emit()
    return true

func remove_item(item_id: String, count: int = 1) -> bool:
    item_removed.emit(item_id, count)
    inventory_changed.emit()
    return true

func drop_random_items(percentage: float) -> void:
    inventory_changed.emit()
