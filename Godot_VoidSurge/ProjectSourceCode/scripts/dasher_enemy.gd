extends EnemyBase
## Dasher: circles the player, then charges in bursts. High speed, low health.

enum State { CIRCLING, WINDING_UP, CHARGING, RECOVERING }

var state: State = State.CIRCLING
var state_timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
var circle_direction: float = 1.0  # 1 or -1

const CIRCLE_TIME: float = 2.0
const WINDUP_TIME: float = 0.4
const CHARGE_TIME: float = 0.3
const RECOVER_TIME: float = 0.8
const CHARGE_SPEED: float = 550.0
const CIRCLE_DISTANCE: float = 200.0


func _ready() -> void:
	super._ready()
	max_health = 18.0
	health = max_health
	move_speed = 160.0
	contact_damage = 18.0
	score_value = 200
	circle_direction = [-1.0, 1.0].pick_random()
	state_timer = randf_range(0.5, CIRCLE_TIME)


func _enemy_behavior(delta: float) -> void:
	var player := _get_player()
	if not player:
		return

	state_timer -= delta
	var to_player := player.global_position - global_position
	var dir := to_player.normalized()

	match state:
		State.CIRCLING:
			# Circle around player at preferred distance
			var tangent := dir.rotated(PI / 2.0 * circle_direction)
			var dist := to_player.length()
			var approach := 0.0
			if dist > CIRCLE_DISTANCE + 30:
				approach = 1.0
			elif dist < CIRCLE_DISTANCE - 30:
				approach = -0.5
			velocity = (tangent + dir * approach).normalized() * move_speed

			if body_sprite:
				body_sprite.rotation = dir.angle()

			if state_timer <= 0.0:
				_enter_state(State.WINDING_UP)

		State.WINDING_UP:
			velocity = Vector2.ZERO
			charge_direction = dir

			# Visual: flash rapidly
			if body_sprite:
				body_sprite.color = Color.WHITE if fmod(state_timer, 0.1) < 0.05 else _original_color
				body_sprite.rotation = dir.angle()

			if state_timer <= 0.0:
				_enter_state(State.CHARGING)

		State.CHARGING:
			velocity = charge_direction * CHARGE_SPEED

			if state_timer <= 0.0:
				_enter_state(State.RECOVERING)

		State.RECOVERING:
			velocity = velocity.move_toward(Vector2.ZERO, 600.0 * delta)

			if state_timer <= 0.0:
				_enter_state(State.CIRCLING)


func _enter_state(new_state: State) -> void:
	state = new_state
	match state:
		State.CIRCLING:
			state_timer = CIRCLE_TIME + randf_range(-0.5, 0.5)
			circle_direction = [-1.0, 1.0].pick_random()
		State.WINDING_UP:
			state_timer = WINDUP_TIME
		State.CHARGING:
			state_timer = CHARGE_TIME
		State.RECOVERING:
			state_timer = RECOVER_TIME
