class_name JsonLoader
extends Node

static func load_json(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    
    var json := JSON.new()
    var error := json.parse(file.get_as_text())
    file.close()
    
    if error != OK:
        return {}
    
    return json.data
