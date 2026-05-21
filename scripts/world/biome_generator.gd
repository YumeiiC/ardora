class_name BiomeGenerator
extends Node

const CHUNK_SIZE := 16
const TILE_SIZE := 16

var noise: FastNoiseLite
var cave_noise: FastNoiseLite

func _ready() -> void:
    noise = FastNoiseLite.new()
    noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    noise.frequency = 0.01

    cave_noise = FastNoiseLite.new()
    cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
    cave_noise.frequency = 0.05

func generate_chunk(chunk_pos: Vector2i, world_seed: int) -> Dictionary:
    noise.seed = world_seed
    cave_noise.seed = world_seed + 1000

    var tiles: Array[Array] = []
    var objects: Array[Dictionary] = []
    var biome := _get_biome(chunk_pos)

    for x in range(CHUNK_SIZE):
        tiles.append([])
        for y in range(CHUNK_SIZE):
            var world_x := chunk_pos.x * CHUNK_SIZE + x
            var world_y := chunk_pos.y * CHUNK_SIZE + y

            var height_value := noise.get_noise_2d(world_x, world_y)
            var cave_value := cave_noise.get_noise_2d(world_x, world_y)

            var tile := _get_tile(biome, world_y, height_value, cave_value)
            tiles[x].append(tile)

            if world_y >= 0 and tile == "grass" and randf() < 0.05:
                var object := _spawn_object(biome, world_x, world_y)
                if object:
                    objects.append(object)

    return {
        "biome": biome,
        "tiles": tiles,
        "objects": objects,
        "modified": false
    }

func _get_biome(chunk_pos: Vector2i) -> String:
    var temp := noise.get_noise_2d(chunk_pos.x * 10, 0)

    if temp < -0.3:
        return "snow"
    elif temp > 0.3:
        return "desert"
    else:
        return "forest"

func _get_tile(biome: String, world_y: int, height: float, cave: float) -> String:
    if world_y < 0:
        if cave > 0.3 and world_y < -3:
            return "air"
        elif world_y < -10:
            return "deep_stone"
        else:
            return "stone"

    match biome:
        "snow":
            if world_y == 0:
                return "snow"
            else:
                return "ice"
        "desert":
            return "sand"
        "forest", _:
            if world_y == 0:
                return "grass"
            else:
                return "dirt"

func _spawn_object(biome: String, x: int, y: int) -> Dictionary:
    var rand := randf()

    match biome:
        "forest":
            if rand < 0.3:
                return {"type": "tree", "x": x, "y": y, "health": 20}
            elif rand < 0.45:
                return {"type": "berry_bush", "x": x, "y": y, "health": 10}
        "snow":
            if rand < 0.2:
                return {"type": "pine_tree", "x": x, "y": y, "health": 25}
        "desert":
            if rand < 0.1:
                return {"type": "cactus", "x": x, "y": y, "health": 15}

    if rand > 0.8:
        return {"type": "rock", "x": x, "y": y, "health": 30}

    return {}
