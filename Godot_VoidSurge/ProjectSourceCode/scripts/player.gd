extends CharacterBody2D
## Player controller: movement, shooting, dashing, and heat management.

signal health_changed(current: float, maximum: float)
signal heat_changed(current: float)
signal dash_cooldown_changed(ratio: float)
signal player_died

# --- State ---
var health: float
var heat: float = 0.0
var is_overheated: bool = false
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_elapsed: float = 0.0
var shoot_timer: float = 0.0
var invincible_timer: float = 0.0

const DASH_DURATION: float = 0.15
const OVERHEAT_PENALTY: float = 15.0       # damage when overheating
const OVERHEAT_LOCKOUT: float = 2.5        # seconds locked out
var overheat_lockout_timer: float = 0.0

# --- Node References ---
@onready var body_sprite: Polygon2D = $BodySprite
@onready var heat_glow: PointLight2D = $HeatGlow if has_node("HeatGlow") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dash_particles: GPUParticles2D = $DashParticles if has_node("DashParticles") else null
@onready var hit_flash_timer: Timer = $HitFlashTimer


func _ready() -> void:
	health = GameManager.player_max_health
	health_changed.emit(health, GameManager.player_max_health)
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not GameManager.is_game_active:
		return

	_handle_timers(delta)
	_handle_health_regen(delta)

	if is_dashing:
		_process_dash(delta)
	else:
		_process_movement(delta)
		_process_shooting(delta)
		_process_dash_input()

	_process_heat(delta)
	_clamp_to_arena()
	_update_visuals()


func _handle_timers(delta: float) -> void:
	shoot_timer = max(0.0, shoot_timer - delta)
	dash_timer = max(0.0, dash_timer - delta)
	invincible_timer = max(0.0, invincible_timer - delta)
	if overheat_lockout_timer > 0.0:
		overheat_lockout_timer = max(0.0, overheat_lockout_timer - delta)
		if overheat_lockout_timer <= 0.0:
			is_overheated = false

	var dash_ratio := 1.0 - (dash_timer / GameManager.player_dash_cooldown) if GameManager.player_dash_cooldown > 0 else 1.0
	dash_cooldown_changed.emit(clampf(dash_ratio, 0.0, 1.0))


func _handle_health_regen(delta: float) -> void:
	if GameManager.player_health_regen > 0.0 and health < GameManager.player_max_health:
		health = minf(health + GameManager.player_health_regen * delta, GameManager.player_max_health)
		health_changed.emit(health, GameManager.player_max_health)


func _process_movement(delta: float) -> void:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	velocity = input_dir * GameManager.player_move_speed
	move_and_slide()

	# Rotate body sprite to face mouse
	var mouse_pos := get_global_mouse_position()
	body_sprite.rotation = (mouse_pos - global_position).angle()


func _process_shooting(_delta: float) -> void:
	if not Input.is_action_pressed("shoot"):
		return
	if shoot_timer > 0.0:
		return
	if is_overheated:
		return

	shoot_timer = GameManager.player_fire_rate

	# Heat bonus damage: up to player_heat_damage_bonus extra at 100% heat
	var heat_ratio := heat / 100.0
	var damage := GameManager.player_damage * (1.0 + heat_ratio * GameManager.player_heat_damage_bonus)

	var aim_dir := (get_global_mouse_position() - global_position).normalized()
	var bullet_count := GameManager.player_bullet_count
	var spread_angle := deg_to_rad(8.0)  # angle between spread bullets

	for i in bullet_count:
		var offset_angle := (i - (bullet_count - 1) / 2.0) * spread_angle
		var dir := aim_dir.rotated(offset_angle)
		_spawn_bullet(dir, damage)

	# Add heat
	heat = minf(heat + GameManager.player_heat_per_shot, 100.0)
	if heat >= 100.0 and not is_overheated:
		_trigger_overheat()

	heat_changed.emit(heat)


func _spawn_bullet(direction: Vector2, damage: float) -> void:
	var bullet_scene := preload("res://scenes/projectiles/player_bullet.tscn")
	var bullet := bullet_scene.instantiate()
	bullet.global_position = global_position + direction * 20.0
	bullet.direction = direction
	bullet.damage = damage
	bullet.pierce_remaining = GameManager.player_bullet_pierce
	get_tree().current_scene.add_child(bullet)


func _process_dash_input() -> void:
	if not Input.is_action_just_pressed("dash"):
		return
	if dash_timer > 0.0:
		return

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()

	if input_dir == Vector2.ZERO:
		# Dash toward mouse if no movement input
		input_dir = (get_global_mouse_position() - global_position).normalized()

	dash_direction = input_dir
	is_dashing = true
	dash_elapsed = 0.0
	dash_timer = GameManager.player_dash_cooldown
	invincible_timer = DASH_DURATION + 0.05  # brief i-frames

	if dash_particles:
		dash_particles.emitting = true


func _process_dash(delta: float) -> void:
	dash_elapsed += delta
	if dash_elapsed >= DASH_DURATION:
		is_dashing = false
		if dash_particles:
			dash_particles.emitting = false
		return

	velocity = dash_direction * GameManager.player_dash_speed
	move_and_slide()

	# Dash damage: hurt enemies we pass through
	_deal_dash_damage()


func _deal_dash_damage() -> void:
	if GameManager.player_dash_damage <= 0:
		return
	var space := get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	query.collision_mask = 2  # enemies layer
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var results := space.intersect_shape(query, 8)
	for result in results:
		var collider = result["collider"]
		if collider.has_method("take_damage") and collider.is_in_group("enemies"):
			if not collider.has_meta("dash_hit_frame") or collider.get_meta("dash_hit_frame") != get_tree().get_frame():
				collider.set_meta("dash_hit_frame", get_tree().get_frame())
				collider.take_damage(GameManager.player_dash_damage)
				_show_hit_effect(collider.global_position)


func _process_heat(delta: float) -> void:
	if not is_overheated and heat > 0.0:
		heat = maxf(0.0, heat - GameManager.player_heat_decay * delta)
		heat_changed.emit(heat)


func _trigger_overheat() -> void:
	is_overheated = true
	overheat_lockout_timer = OVERHEAT_LOCKOUT
	take_damage(OVERHEAT_PENALTY)
	# Visual flash for overheat
	_flash_color(Color.ORANGE)


func _clamp_to_arena() -> void:
	var half := GameManager.ARENA_SIZE / 2.0
	global_position.x = clampf(global_position.x, -half.x, half.x)
	global_position.y = clampf(global_position.y, -half.y, half.y)


func take_damage(amount: float) -> void:
	if invincible_timer > 0.0 and amount != OVERHEAT_PENALTY:
		return

	health -= amount
	health_changed.emit(health, GameManager.player_max_health)

	_flash_color(Color.RED)
	_trigger_screen_shake()

	if health <= 0.0:
		health = 0.0
		player_died.emit()
		GameManager.trigger_game_over()


func heal(amount: float) -> void:
	health = minf(health + amount, GameManager.player_max_health)
	health_changed.emit(health, GameManager.player_max_health)


func refresh_stats() -> void:
	## Called after upgrades to sync max health etc.
	if health > GameManager.player_max_health:
		health = GameManager.player_max_health
	elif GameManager.player_max_health > health:
		# Heal the difference when max health increases
		health = GameManager.player_max_health
	health_changed.emit(health, GameManager.player_max_health)


func _update_visuals() -> void:
	var heat_ratio := heat / 100.0
	# Tint body from cyan to orange/red based on heat
	var base_color := Color.CYAN
	var hot_color := Color.ORANGE_RED
	body_sprite.color = base_color.lerp(hot_color, heat_ratio)

	if is_overheated:
		body_sprite.color = Color.DARK_RED if fmod(overheat_lockout_timer, 0.2) < 0.1 else Color.ORANGE

	if invincible_timer > 0.0 and not is_overheated:
		body_sprite.modulate.a = 0.5 if fmod(invincible_timer, 0.15) < 0.075 else 1.0
	else:
		body_sprite.modulate.a = 1.0


func _flash_color(color: Color) -> void:
	body_sprite.color = color
	if hit_flash_timer:
		hit_flash_timer.start(0.1)


func _on_hit_flash_timer_timeout() -> void:
	pass  # visuals update next frame anyway


func _show_hit_effect(pos: Vector2) -> void:
	# Spawn a brief hit effect at position
	var effect := Sprite2D.new()
	effect.texture = _create_circle_texture(8, Color.WHITE)
	effect.global_position = pos
	effect.z_index = 10
	get_tree().current_scene.add_child(effect)

	var tween := effect.create_tween()
	tween.set_parallel(true)
	tween.tween_property(effect, "modulate:a", 0.0, 0.15)
	tween.tween_property(effect, "scale", Vector2(2.5, 2.5), 0.15)
	tween.chain().tween_callback(effect.queue_free)


func _trigger_screen_shake() -> void:
	var camera := get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(6.0, 0.2)


func _create_circle_texture(radius: int, color: Color) -> ImageTexture:
	var img := Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
	var center := Vector2(radius, radius)
	for x in radius * 2:
		for y in radius * 2:
			if Vector2(x, y).distance_to(center) <= radius:
				img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)
