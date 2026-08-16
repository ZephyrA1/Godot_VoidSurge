extends Node
## Global game state manager. Persists between scenes.

signal score_changed(new_score: int)
signal wave_changed(new_wave: int)
signal game_over_triggered
signal game_won_triggered

# --- Run State ---
var score: int = 0
var current_wave: int = 0
var enemies_alive: int = 0
var is_game_active: bool = false

# --- Player Stats (modified by upgrades) ---
var player_max_health: float = 100.0
var player_damage: float = 10.0
var player_fire_rate: float = 0.18          # seconds between shots
var player_move_speed: float = 280.0
var player_heat_per_shot: float = 8.0
var player_heat_decay: float = 25.0         # per second
var player_heat_damage_bonus: float = 0.5   # % bonus at max heat
var player_dash_cooldown: float = 1.2
var player_dash_damage: float = 30.0
var player_dash_speed: float = 800.0
var player_bullet_count: int = 1            # spread shot count
var player_bullet_pierce: int = 0           # how many enemies a bullet passes through
var player_health_regen: float = 0.0        # per second

# --- Upgrade Tracking ---
var upgrades_chosen: Array[String] = []

# --- Constants ---
const TOTAL_WAVES: int = 10
const ARENA_SIZE: Vector2 = Vector2(1100, 600)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func start_new_run() -> void:
	score = 0
	current_wave = 0
	enemies_alive = 0
	is_game_active = true
	upgrades_chosen.clear()
	_reset_player_stats()


func _reset_player_stats() -> void:
	player_max_health = 100.0
	player_damage = 10.0
	player_fire_rate = 0.18
	player_move_speed = 280.0
	player_heat_per_shot = 8.0
	player_heat_decay = 25.0
	player_heat_damage_bonus = 0.5
	player_dash_cooldown = 1.2
	player_dash_damage = 30.0
	player_dash_speed = 800.0
	player_bullet_count = 1
	player_bullet_pierce = 0
	player_health_regen = 0.0


func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)


func set_wave(wave: int) -> void:
	current_wave = wave
	wave_changed.emit(current_wave)


func trigger_game_over() -> void:
	is_game_active = false
	game_over_triggered.emit()


func trigger_win() -> void:
	is_game_active = false
	game_won_triggered.emit()


func apply_upgrade(upgrade_id: String) -> void:
	upgrades_chosen.append(upgrade_id)
	match upgrade_id:
		"damage_up":
			player_damage += 4.0
		"fire_rate_up":
			player_fire_rate = max(0.06, player_fire_rate - 0.03)
		"heat_reduction":
			player_heat_per_shot = max(2.0, player_heat_per_shot - 2.0)
			player_heat_decay += 5.0
		"heat_damage_bonus":
			player_heat_damage_bonus += 0.25
		"dash_damage_up":
			player_dash_damage += 20.0
		"dash_cooldown_down":
			player_dash_cooldown = max(0.3, player_dash_cooldown - 0.25)
		"max_health_up":
			player_max_health += 30.0
		"health_regen":
			player_health_regen += 2.0
		"spread_shot":
			player_bullet_count = min(7, player_bullet_count + 2)
		"piercing_shot":
			player_bullet_pierce += 1
		"move_speed_up":
			player_move_speed += 35.0


func get_upgrade_pool() -> Array[Dictionary]:
	## Returns all possible upgrades with display info.
	return [
		{"id": "damage_up", "name": "Power Shot", "desc": "Bullet damage +4", "color": Color.ORANGE_RED},
		{"id": "fire_rate_up", "name": "Rapid Fire", "desc": "Fire rate increases", "color": Color.YELLOW},
		{"id": "heat_reduction", "name": "Coolant System", "desc": "Less heat per shot, faster decay", "color": Color.DEEP_SKY_BLUE},
		{"id": "heat_damage_bonus", "name": "Pyromaniac", "desc": "More bonus damage at high heat", "color": Color.ORANGE},
		{"id": "dash_damage_up", "name": "Blade Dash", "desc": "Dash damage +20", "color": Color.MEDIUM_PURPLE},
		{"id": "dash_cooldown_down", "name": "Quick Step", "desc": "Dash recharges faster", "color": Color.AQUAMARINE},
		{"id": "max_health_up", "name": "Reinforced Hull", "desc": "Max health +30", "color": Color.GREEN},
		{"id": "health_regen", "name": "Auto Repair", "desc": "Slowly regenerate health", "color": Color.LIME_GREEN},
		{"id": "spread_shot", "name": "Scatter Cannon", "desc": "Fire +2 bullets in a spread", "color": Color.GOLD},
		{"id": "piercing_shot", "name": "Piercing Rounds", "desc": "Bullets pass through +1 enemy", "color": Color.CYAN},
		{"id": "move_speed_up", "name": "Thrusters", "desc": "Movement speed increases", "color": Color.WHITE},
	]


func pick_random_upgrades(count: int = 3) -> Array[Dictionary]:
	var pool := get_upgrade_pool()
	pool.shuffle()
	var result: Array[Dictionary] = []
	for i in mini(count, pool.size()):
		result.append(pool[i])
	return result
