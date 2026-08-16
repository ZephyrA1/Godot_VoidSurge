extends Node2D
## Main game scene controller. Manages wave flow, upgrade transitions, and arena setup.

@onready var player: CharacterBody2D = $Player
@onready var wave_manager: Node = $WaveManager
@onready var hud: CanvasLayer = $HUD
@onready var upgrade_panel: CanvasLayer = $UpgradePanel
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var game_over_screen: CanvasLayer = $GameOverScreen
@onready var win_screen: CanvasLayer = $WinScreen
@onready var camera: Camera2D = $GameCamera
@onready var arena_border: Node2D = $ArenaBorder

var _between_waves: bool = false
var _wave_delay_timer: float = 0.0
const WAVE_DELAY: float = 1.5


func _ready() -> void:
	GameManager.start_new_run()
	_draw_arena_border()

	# Connect player signals
	player.health_changed.connect(hud.update_health)
	player.heat_changed.connect(hud.update_heat)
	player.dash_cooldown_changed.connect(hud.update_dash_cooldown)
	player.player_died.connect(_on_player_died)

	# Connect wave manager signals
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	wave_manager.all_waves_complete.connect(_on_all_waves_complete)

	# Connect upgrade panel
	upgrade_panel.upgrade_chosen.connect(_on_upgrade_chosen)

	# Connect game manager signals
	GameManager.game_over_triggered.connect(_on_game_over)
	GameManager.game_won_triggered.connect(_on_game_won)

	# Start first wave after brief delay
	_between_waves = true
	_wave_delay_timer = 1.0


func _physics_process(delta: float) -> void:
	if _between_waves:
		_wave_delay_timer -= delta
		if _wave_delay_timer <= 0.0:
			_between_waves = false
			_start_next_wave()

	# Update HUD enemies count
	if wave_manager:
		hud.update_enemies_remaining(wave_manager.get_enemies_remaining())


func _start_next_wave() -> void:
	var next_wave := GameManager.current_wave + 1
	wave_manager.start_wave(next_wave)
	hud.show_wave_banner(next_wave)


func _on_wave_cleared() -> void:
	# Show upgrade selection between waves
	upgrade_panel.show_upgrades()


func _on_upgrade_chosen() -> void:
	# Refresh player stats after upgrade
	player.refresh_stats()

	# Brief delay before next wave
	_between_waves = true
	_wave_delay_timer = WAVE_DELAY


func _on_all_waves_complete() -> void:
	GameManager.trigger_win()


func _on_player_died() -> void:
	# Handled by game_over signal
	pass


func _on_game_over() -> void:
	game_over_screen.show_game_over()


func _on_game_won() -> void:
	win_screen.show_win()


func _draw_arena_border() -> void:
	# Draw arena boundary lines
	var half := GameManager.ARENA_SIZE / 2.0
	var corners: Array[Vector2] = [
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y),
	]

	var border := Line2D.new()
	border.width = 3.0
	border.default_color = Color(0.3, 0.4, 0.6, 0.8)
	for corner in corners:
		border.add_point(corner)
	border.add_point(corners[0])  # close the loop
	arena_border.add_child(border)

	# Add corner accents
	for corner in corners:
		var accent := Line2D.new()
		accent.width = 2.0
		accent.default_color = Color.CYAN * Color(1, 1, 1, 0.5)
		var dir_to_center := -corner.normalized() * 30.0
		accent.add_point(corner)
		accent.add_point(corner + Vector2(dir_to_center.x, 0))
		arena_border.add_child(accent)

		var accent2 := Line2D.new()
		accent2.width = 2.0
		accent2.default_color = Color.CYAN * Color(1, 1, 1, 0.5)
		accent2.add_point(corner)
		accent2.add_point(corner + Vector2(0, dir_to_center.y))
		arena_border.add_child(accent2)

	# Add static body walls for collision
	_create_arena_walls(half)


func _create_arena_walls(half: Vector2) -> void:
	# Top wall
	_add_wall(Vector2(0, -half.y - 16), Vector2(half.x * 2 + 32, 32))
	# Bottom wall
	_add_wall(Vector2(0, half.y + 16), Vector2(half.x * 2 + 32, 32))
	# Left wall
	_add_wall(Vector2(-half.x - 16, 0), Vector2(32, half.y * 2 + 32))
	# Right wall
	_add_wall(Vector2(half.x + 16, 0), Vector2(32, half.y * 2 + 32))


func _add_wall(pos: Vector2, size: Vector2) -> void:
	var wall := StaticBody2D.new()
	wall.position = pos
	wall.collision_layer = 16  # layer 5: arena_walls
	wall.collision_mask = 0

	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	wall.add_child(shape)

	arena_border.add_child(wall)
