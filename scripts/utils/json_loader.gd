class_name JsonLoader
extends Node

static func load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Failed to load JSON: " + path)
        return {}

    var json := JSON.new()
    var error := json.parse(file.get_as_text())
    file.close()

    if error != OK:
        push_error("Failed to parse JSON: " + path)
        return {}

    return json.data

static func save_json(path: String, data: Dictionary) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        push_error("Failed to save JSON: " + path)
        return false

    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    return true
