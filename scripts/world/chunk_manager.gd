extends Node2D

const CHUNK_SIZE := 16
const TILE_SIZE := 16
const RENDER_DISTANCE := 3

var chunks: Dictionary = {}
var active_chunks: Array[Vector2i] = []

func _process(_delta: float) -> void:
    pass

func _world_to_chunk(pos: Vector2) -> Vector2i:
    return Vector2i(
        floor(pos.x / (CHUNK_SIZE * TILE_SIZE)),
        floor(pos.y / (CHUNK_SIZE * TILE_SIZE))
    )
