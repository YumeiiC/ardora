class_name ChunkManager
extends Node2D

const CHUNK_SIZE := 16
const TILE_SIZE := 16
const RENDER_DISTANCE := 3
const UNLOAD_DISTANCE := 5

var chunks: Dictionary = {}
var active_chunks: Array[Vector2i] = []
var modified_chunks: Dictionary = {}

@onready var player: Node2D
@onready var biome_generator: Node = $BiomeGenerator

func _ready() -> void:
    await get_tree().process_frame
    player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
    if player == null:
        return
    _update_active_chunks()

func _update_active_chunks() -> void:
    var player_chunk := _world_to_chunk(player.global_position)
    var new_active: Array[Vector2i] = []

    for x in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
        for y in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
            var chunk_pos := player_chunk + Vector2i(x, y)
            new_active.append(chunk_pos)
            if not chunks.has(chunk_pos):
                _load_chunk(chunk_pos)

    for chunk_pos in active_chunks:
        if not new_active.has(chunk_pos):
            _unload_chunk(chunk_pos)

    active_chunks = new_active

func _world_to_chunk(pos: Vector2) -> Vector2i:
    return Vector2i(
        floor(pos.x / (CHUNK_SIZE * TILE_SIZE)),
        floor(pos.y / (CHUNK_SIZE * TILE_SIZE))
    )

func _load_chunk(pos: Vector2i) -> void:
    var chunk = preload("res://scenes/world/Chunk.tscn").instantiate()
    chunk.position = Vector2(pos.x * CHUNK_SIZE * TILE_SIZE, pos.y * CHUNK_SIZE * TILE_SIZE)
    chunk.chunk_position = pos

    var chunk_data := _get_chunk_data(pos)
    chunk.generate(chunk_data)

    add_child(chunk)
    chunks[pos] = chunk

func _unload_chunk(pos: Vector2i) -> void:
    if not chunks.has(pos):
        return

    var chunk = chunks[pos]
    if chunk.is_modified:
        modified_chunks[str(pos)] = chunk.serialize()

    chunk.queue_free()
    chunks.erase(pos)

func _get_chunk_data(pos: Vector2i) -> Dictionary:
    var key := str(pos)
    if modified_chunks.has(key):
        return modified_chunks[key]

    return biome_generator.generate_chunk(pos, GameManager.world_seed)

func modify_tile(chunk_pos: Vector2i, local_pos: Vector2i, new_tile: String) -> void:
    if chunks.has(chunk_pos):
        chunks[chunk_pos].set_tile(local_pos, new_tile)

func get_tile_at(world_pos: Vector2) -> String:
    var chunk_pos := _world_to_chunk(world_pos)
    if chunks.has(chunk_pos):
        var local_pos := Vector2i(
            int(world_pos.x) % (CHUNK_SIZE * TILE_SIZE) / TILE_SIZE,
            int(world_pos.y) % (CHUNK_SIZE * TILE_SIZE) / TILE_SIZE
        )
        return chunks[chunk_pos].get_tile(local_pos)
    return ""

func serialize_modified_chunks() -> Dictionary:
    for pos in chunks:
        if chunks[pos].is_modified:
            modified_chunks[str(pos)] = chunks[pos].serialize()
    return modified_chunks
