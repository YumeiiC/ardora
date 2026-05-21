class_name CombatSystem
extends Node

@onready var player: CharacterBody2D = get_parent()

var attack_cooldown: float = 0.0
var is_attacking: bool = false

func _process(delta: float) -> void:
    if attack_cooldown > 0:
        attack_cooldown -= delta

func attack() -> void:
    if is_attacking or attack_cooldown > 0:
        return

    if not player.stats.consume_stamina(8.0):
        return

    is_attacking = true
    attack_cooldown = 0.5

    # Play attack animation
    var sprite := player.get_node("AnimatedSprite2D")
    sprite.play("attack")

    # Detect hit
    var attack_dir := player.facing_direction
    var query := PhysicsShapeQueryParameters2D.new()
    var rect := RectangleShape2D.new()
    rect.size = Vector2(40, 30)
    query.shape = rect
    query.transform = Transform2D(0, player.global_position + attack_dir * 25)
    query.collision_mask = 1 << 2 | 1 << 3  # Enemies + Resources

    var results := player.get_world_2d().direct_space_state.intersect_shape(query, 5)

    for result in results:
        var collider := result.collider as Node2D
        if collider.has_method("take_damage"):
            var damage := _calculate_damage()
            collider.take_damage(damage, player)
            AudioManager.play_sfx("hit")

    await sprite.animation_finished
    is_attacking = false

func _calculate_damage() -> int:
    var base_damage := 2
    var player_inv = player.inventory

    if player_inv.equipped_weapon != "":
        var item_data := _get_item_data(player_inv.equipped_weapon)
        base_damage = item_data.get("damage", 2)

    return base_damage

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
