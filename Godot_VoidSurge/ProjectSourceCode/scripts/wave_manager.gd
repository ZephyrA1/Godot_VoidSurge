extends Node
## Manages wave spawning, enemy counts, and wave transitions.

signal wave_started(wave_number: int)
signal wave_cleared
signal all_waves_complete

var current_wave: int = 0
var enemies_remaining: int = 0
var is_spawning: bool = false
var spawn_timer: float = 0.0
var enemies_to_spawn: Array[Dictionary] = []

const SPAWN_INTERVAL: float = 0.4
const SPAWN_MARGIN: float = 60.0

var chaser_scene := preload("res://scenes/enemies/chaser_enemy.tscn")
var shooter_scene := preload("res://scenes/enemies/shooter_enemy.tscn")
var dasher_scene := preload("res://scenes/enemies/dasher_enemy.tscn")


func start_wave(wave_number: int) -> void:
	current_wave = wave_number
	GameManager.set_wave(wave_number)
	enemies_to_spawn = _generate_wave(wave_number)
	enemies_remaining = enemies_to_spawn.size()
	is_spawning = true
	spawn_timer = 0.2  # brief delay before first spawn
	wave_started.emit(wave_number)


func _physics_process(delta: float) -> void:
	if not is_spawning or enemies_to_spawn.is_empty():
		return

	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = SPAWN_INTERVAL
		_spawn_next_enemy()


func _spawn_next_enemy() -> void:
	if enemies_to_spawn.is_empty():
		is_spawning = false
		return

	var enemy_data: Dictionary = enemies_to_spawn.pop_front()
	var scene: PackedScene = enemy_data["scene"]
	var enemy := scene.instantiate() as EnemyBase

	enemy.global_position = _get_spawn_position()
	enemy.enemy_died.connect(_on_enemy_died)

	# Scale enemy stats with wave number
	var wave_scale := 1.0 + (current_wave - 1) * 0.12
	enemy.max_health *= wave_scale
	enemy.health = enemy.max_health
	enemy.contact_damage *= (1.0 + (current_wave - 1) * 0.08)

	get_tree().current_scene.add_child(enemy)

	if enemies_to_spawn.is_empty():
		is_spawning = false


func _on_enemy_died(_enemy: EnemyBase) -> void:
	enemies_remaining -= 1
	if enemies_remaining <= 0 and not is_spawning:
		if current_wave >= GameManager.TOTAL_WAVES:
			all_waves_complete.emit()
		else:
			wave_cleared.emit()


func _generate_wave(wave: int) -> Array[Dictionary]:
	var enemies: Array[Dictionary] = []

	# Base counts scale with wave
	var chaser_count: int = 3 + wave
	var shooter_count: int = maxi(0, wave - 1)
	var dasher_count: int = maxi(0, wave - 3)

	# Boss wave: wave 10 adds extra strong enemies
	if wave == GameManager.TOTAL_WAVES:
		chaser_count += 4
		shooter_count += 3
		dasher_count += 3

	for i in chaser_count:
		enemies.append({"scene": chaser_scene})
	for i in shooter_count:
		enemies.append({"scene": shooter_scene})
	for i in dasher_count:
		enemies.append({"scene": dasher_scene})

	enemies.shuffle()
	return enemies


func _get_spawn_position() -> Vector2:
	var half := GameManager.ARENA_SIZE / 2.0
	# Spawn at edges of the arena
	var side := randi() % 4
	var pos := Vector2.ZERO
	match side:
		0:  # top
			pos = Vector2(randf_range(-half.x + SPAWN_MARGIN, half.x - SPAWN_MARGIN), -half.y + SPAWN_MARGIN)
		1:  # bottom
			pos = Vector2(randf_range(-half.x + SPAWN_MARGIN, half.x - SPAWN_MARGIN), half.y - SPAWN_MARGIN)
		2:  # left
			pos = Vector2(-half.x + SPAWN_MARGIN, randf_range(-half.y + SPAWN_MARGIN, half.y - SPAWN_MARGIN))
		3:  # right
			pos = Vector2(half.x - SPAWN_MARGIN, randf_range(-half.y + SPAWN_MARGIN, half.y - SPAWN_MARGIN))
	return pos


func get_enemies_remaining() -> int:
	return enemies_remaining
