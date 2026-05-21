class_name Player
extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats: Node = $PlayerStats
@onready var inventory: Node = $Inventory
@onready var combat: Node = $CombatSystem
@onready var input_handler: Node = $PlayerInput

const SPEED := 100.0
const SPRINT_SPEED := 160.0
const ACCELERATION := 800.0
const FRICTION := 800.0

var facing_direction: Vector2 = Vector2.RIGHT
var is_sprinting: bool = false

func _ready() -> void:
    add_to_group("player")
    stats.stamina_changed.connect(_on_stamina_changed)
    stats.player_died.connect(_on_player_died)

    # Load saved data if exists
    if GameManager.player_data.has("position"):
        var pos = GameManager.player_data.position
        global_position = Vector2(pos.x, pos.y)

    if GameManager.player_data.has("stats"):
        var saved_stats = GameManager.player_data.stats
        stats.current_health = saved_stats.get("health", stats.max_health)
        stats.current_stamina = saved_stats.get("stamina", stats.max_stamina)
        stats.current_hunger = saved_stats.get("hunger", stats.max_hunger)
        stats.current_thirst = saved_stats.get("thirst", stats.max_thirst)

func _physics_process(delta: float) -> void:
    if GameManager.is_paused:
        return

    _handle_movement(delta)
    _handle_animation()
    _update_facing()

func _handle_movement(delta: float) -> void:
    var input_dir := input_handler.get_movement_direction()

    is_sprinting = input_handler.is_sprinting() and stats.current_stamina > 10.0

    var target_speed := SPRINT_SPEED if is_sprinting else SPEED

    if is_sprinting and input_dir != Vector2.ZERO:
        stats.consume_stamina(20.0 * delta)

    if input_dir != Vector2.ZERO:
        velocity = velocity.move_toward(input_dir * target_speed, ACCELERATION * delta)
    else:
        velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

    move_and_slide()

func _handle_animation() -> void:
    if velocity.length() > 10.0:
        if is_sprinting:
            sprite.play("run")
        else:
            sprite.play("walk")
    else:
        sprite.play("idle")

func _update_facing() -> void:
    if velocity.x > 10.0:
        facing_direction = Vector2.RIGHT
        sprite.flip_h = false
    elif velocity.x < -10.0:
        facing_direction = Vector2.LEFT
        sprite.flip_h = true

func _on_stamina_changed(current: float, _maximum: float) -> void:
    if current <= 0.0:
        is_sprinting = false

func _on_player_died() -> void:
    UIManager.show_death_screen()
    set_physics_process(false)

    await get_tree().create_timer(3.0).timeout

    global_position = Vector2.ZERO
    stats.current_health = stats.max_health
    stats.current_stamina = stats.max_stamina

    inventory.drop_random_items(0.5)

    set_physics_process(true)
    UIManager.hide_death_screen()

func interact() -> void:
    var interact_range := 40.0
    var query := PhysicsShapeQueryParameters2D.new()
    var circle := CircleShape2D.new()
    circle.radius = interact_range
    query.shape = circle
    query.transform = global_transform
    query.collision_mask = 1 << 3 | 1 << 4 | 1 << 5

    var results := get_world_2d().direct_space_state.intersect_shape(query, 10)

    for result in results:
        var collider := result.collider as Node2D
        if collider.has_method("interact"):
            collider.interact(self)
            break

func gather(node: Node2D) -> void:
    if node.has_method("gather"):
        var stamina_cost := node.get("stamina_cost") if node.get("stamina_cost") else 5.0
        if stats.consume_stamina(stamina_cost):
            node.gather(self)
            AudioManager.play_sfx("chop")
