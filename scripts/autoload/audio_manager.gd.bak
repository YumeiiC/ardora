extends Node

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var current_bgm: String = ""
var music_tracks: Dictionary = {
    "menu": preload("res://assets/audio/music/menu_theme.ogg"),
    "day": preload("res://assets/audio/music/day_theme.ogg"),
    "night": preload("res://assets/audio/music/night_theme.ogg"),
    "cave": preload("res://assets/audio/music/cave_theme.ogg")
}

var sfx_tracks: Dictionary = {
    "chop": preload("res://assets/audio/sfx/chop.ogg"),
    "mine": preload("res://assets/audio/sfx/mine.ogg"),
    "hit": preload("res://assets/audio/sfx/hit.ogg"),
    "step_grass": preload("res://assets/audio/sfx/step_grass.ogg"),
    "eat": preload("res://assets/audio/sfx/eat.ogg"),
    "craft": preload("res://assets/audio/sfx/craft.ogg")
}

func _ready() -> void:
    bgm_player.bus = "Music"
    sfx_player.bus = "SFX"

func play_bgm(track_name: String, fade_duration: float = 1.0) -> void:
    if current_bgm == track_name:
        return

    if not music_tracks.has(track_name):
        push_warning("BGM track not found: " + track_name)
        return

    current_bgm = track_name
    var tween := create_tween()
    tween.tween_property(bgm_player, "volume_db", -40.0, fade_duration)
    tween.tween_callback(func():
        bgm_player.stream = music_tracks[track_name]
        bgm_player.play()
        create_tween().tween_property(bgm_player, "volume_db", 0.0, fade_duration)
    )

func play_sfx(sfx_name: String, random_pitch: bool = true) -> void:
    if not sfx_tracks.has(sfx_name):
        push_warning("SFX not found: " + sfx_name)
        return

    var player := AudioStreamPlayer.new()
    player.stream = sfx_tracks[sfx_name]
    player.bus = "SFX"
    if random_pitch:
        player.pitch_scale = randf_range(0.9, 1.1)
    add_child(player)
    player.play()
    await player.finished
    player.queue_free()

func stop_bgm(fade_duration: float = 1.0) -> void:
    var tween := create_tween()
    tween.tween_property(bgm_player, "volume_db", -40.0, fade_duration)
    tween.tween_callback(func():
        bgm_player.stop()
        current_bgm = ""
    )

func set_bgm_volume(volume: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(volume))

func set_sfx_volume(volume: float) -> void:
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(volume))
