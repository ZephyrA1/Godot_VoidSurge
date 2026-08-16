extends CanvasLayer
## Game over screen shown when the player dies.

signal restart_requested
signal menu_requested

@onready var score_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScoreLabel
@onready var wave_label: Label = $CenterContainer/PanelContainer/VBoxContainer/WaveLabel
@onready var restart_button: Button = $CenterContainer/PanelContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $CenterContainer/PanelContainer/VBoxContainer/MenuButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart)
	menu_button.pressed.connect(_on_menu)


func show_game_over() -> void:
	score_label.text = "Score: %d" % GameManager.score
	wave_label.text = "Reached Wave %d / %d" % [GameManager.current_wave, GameManager.TOTAL_WAVES]
	visible = true
	get_tree().paused = true
	restart_button.grab_focus()


func _on_restart() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_menu() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
