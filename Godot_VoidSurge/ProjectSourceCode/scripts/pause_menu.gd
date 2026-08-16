extends CanvasLayer
## Pause menu with resume, restart, and quit options.

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var resume_button: Button = $CenterContainer/PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $CenterContainer/PanelContainer/VBoxContainer/RestartButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/VBoxContainer/QuitButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_button.pressed.connect(_on_resume)
	restart_button.pressed.connect(_on_restart)
	quit_button.pressed.connect(_on_quit)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and GameManager.is_game_active:
		if visible:
			_on_resume()
		else:
			_show_pause()
		get_viewport().set_input_as_handled()


func _show_pause() -> void:
	visible = true
	get_tree().paused = true


func _on_resume() -> void:
	visible = false
	get_tree().paused = false


func _on_restart() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_quit() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
