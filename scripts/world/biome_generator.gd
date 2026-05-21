extends Node

func generate_chunk(chunk_pos: Vector2i, world_seed: int) -> Dictionary:
    return {
        "biome": "forest",
        "tiles": [],
        "objects": [],
        "modified": false
    }
