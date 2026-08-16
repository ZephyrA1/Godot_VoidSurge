extends CharacterBody2D
class_name EnemyBase
## Base class for all enemies. Handles health, damage flash, death, and scoring.

signal enemy_died(enemy: EnemyBase)

@export var max_health: float = 30.0
@export var move_speed: float = 120.0
@export var contact_damage: float = 10.0
@export var score_value: int = 100

var health: float
var is_dead: bool = false
var _flash_timer: float = 0.0
var _original_color: Color = Color.RED
var _knockback_velocity: Vector2 = Vector2.ZERO
var _contact_cooldown: float = 0.0
const CONTACT_COOLDOWN_TIME: float = 0.5

@onready var body_sprite: Polygon2D = $BodySprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	if body_sprite:
		_original_color = body_sprite.color


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_flash_timer = maxf(0.0, _flash_timer - delta)
	_contact_cooldown = maxf(0.0, _contact_cooldown - delta)
	if _flash_timer <= 0.0 and body_sprite:
		body_sprite.color = _original_color

	# Apply knockback decay
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 800.0 * delta)

	_enemy_behavior(delta)

	velocity += _knockback_velocity
	move_and_slide()

	_check_player_contact()
	_clamp_to_arena()


func _enemy_behavior(_delta: float) -> void:
	## Override in subclasses for specific AI.
	pass


func take_damage(amount: float) -> void:
	if is_dead:
		return

	health -= amount
	_flash_timer = 0.1
	if body_sprite:
		body_sprite.color = Color.WHITE

	# Knockback away from player
	var player := _get_player()
	if player:
		_knockback_velocity = (global_position - player.global_position).normalized() * 200.0

	if health <= 0.0:
		die()


func die() -> void:
	is_dead = true
	GameManager.add_score(score_value)
	enemy_died.emit(self)
	_spawn_death_effect()
	queue_free()


func _spawn_death_effect() -> void:
	# Expanding ring effect on death
	for i in 6:
		var particle := Sprite2D.new()
		var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		img.fill(_original_color)
		particle.texture = ImageTexture.create_from_image(img)
		particle.global_position = global_position
		particle.z_index = 5
		get_tree().current_scene.add_child(particle)

		var angle := TAU * i / 6.0
		var target_pos := global_position + Vector2.from_angle(angle) * 40.0
		var tween := particle.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", target_pos, 0.25)
		tween.tween_property(particle, "modulate:a", 0.0, 0.25)
		tween.chain().tween_callback(particle.queue_free)


func _get_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	return null


func _check_player_contact() -> void:
	if _contact_cooldown > 0.0:
		return
	var player := _get_player()
	if player and global_position.distance_to(player.global_position) < 28.0:
		if player.has_method("take_damage"):
			player.take_damage(contact_damage)
			_contact_cooldown = CONTACT_COOLDOWN_TIME


func _clamp_to_arena() -> void:
	var half := GameManager.ARENA_SIZE / 2.0
	global_position.x = clampf(global_position.x, -half.x, half.x)
	global_position.y = clampf(global_position.y, -half.y, half.y)
