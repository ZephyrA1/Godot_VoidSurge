extends EnemyBase
## Shooter: keeps distance from the player and fires projectiles.

var shoot_timer: float = 0.0
var preferred_distance: float = 280.0

const SHOOT_INTERVAL: float = 1.8
const BULLET_SPEED: float = 300.0


func _ready() -> void:
	super._ready()
	max_health = 20.0
	health = max_health
	move_speed = 90.0
	contact_damage = 8.0
	score_value = 150
	shoot_timer = randf_range(0.3, SHOOT_INTERVAL)


func _enemy_behavior(delta: float) -> void:
	var player := _get_player()
	if not player:
		return

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var dir := to_player.normalized()

	# Try to maintain preferred distance
	if dist < preferred_distance - 40.0:
		velocity = -dir * move_speed  # back away
	elif dist > preferred_distance + 60.0:
		velocity = dir * move_speed * 0.7  # approach slowly
	else:
		# Strafe perpendicular
		velocity = dir.rotated(PI / 2.0) * move_speed * 0.5

	if body_sprite:
		body_sprite.rotation = dir.angle()

	# Shooting
	shoot_timer -= delta
	if shoot_timer <= 0.0:
		shoot_timer = SHOOT_INTERVAL
		_fire_at_player(dir)


func _fire_at_player(direction: Vector2) -> void:
	var bullet_scene := preload("res://scenes/projectiles/enemy_bullet.tscn")
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position + direction * 16.0
	bullet.direction = direction
	bullet.speed = BULLET_SPEED
	bullet.damage = 8.0 + GameManager.current_wave * 0.5
	get_tree().current_scene.add_child(bullet)
