extends CanvasLayer
## Victory screen shown when the player clears all waves.

@onready var score_label: Label = $CenterContainer/PanelContainer/VBoxContainer/ScoreLabel
@onready var upgrades_label: Label = $CenterContainer/PanelContainer/VBoxContainer/UpgradesLabel
@onready var restart_button: Button = $CenterContainer/PanelContainer/VBoxContainer/RestartButton
@onready var menu_button: Button = $CenterContainer/PanelContainer/VBoxContainer/MenuButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart)
	menu_button.pressed.connect(_on_menu)


func show_win() -> void:
	score_label.text = "Final Score: %d" % GameManager.score
	upgrades_label.text = "Upgrades: %d chosen" % GameManager.upgrades_chosen.size()
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
