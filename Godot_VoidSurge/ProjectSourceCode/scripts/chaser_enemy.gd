extends EnemyBase
## Chaser: moves directly toward the player. Simple but threatening in groups.


func _ready() -> void:
	super._ready()
	max_health = 25.0
	health = max_health
	move_speed = 130.0
	contact_damage = 12.0
	score_value = 100


func _enemy_behavior(_delta: float) -> void:
	var player := _get_player()
	if not player:
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * move_speed

	if body_sprite:
		body_sprite.rotation = dir.angle()
