extends CanvasLayer
## Heads-up display: health bar, heat bar, dash indicator, wave info, score.

@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/HealthBar
@onready var health_label: Label = $MarginContainer/VBoxContainer/TopBar/HealthBar/HealthLabel
@onready var heat_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/HeatBar
@onready var heat_label: Label = $MarginContainer/VBoxContainer/TopBar/HeatBar/HeatLabel
@onready var dash_bar: ProgressBar = $MarginContainer/VBoxContainer/TopBar/DashBar
@onready var wave_label: Label = $MarginContainer/VBoxContainer/TopBar/WaveLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/TopBar/ScoreLabel
@onready var enemies_label: Label = $MarginContainer/VBoxContainer/TopBar/EnemiesLabel
@onready var wave_banner: Label = $WaveBanner
@onready var overheat_warning: Label = $OverheatWarning


func _ready() -> void:
	wave_banner.visible = false
	overheat_warning.visible = false
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.wave_changed.connect(_on_wave_changed)


func update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d/%d" % [ceili(current), ceili(maximum)]

	# Color shifts based on health ratio
	var ratio := current / maximum
	var style := health_bar.get("theme_override_styles/fill") as StyleBoxFlat
	if style:
		if ratio > 0.5:
			style.bg_color = Color.GREEN
		elif ratio > 0.25:
			style.bg_color = Color.YELLOW
		else:
			style.bg_color = Color.RED


func update_heat(current: float) -> void:
	heat_bar.value = current
	heat_label.text = "HEAT %d%%" % [ceili(current)]

	var style := heat_bar.get("theme_override_styles/fill") as StyleBoxFlat
	if style:
		if current < 50:
			style.bg_color = Color.DEEP_SKY_BLUE
		elif current < 80:
			style.bg_color = Color.ORANGE
		else:
			style.bg_color = Color.RED

	overheat_warning.visible = current >= 100.0


func update_dash_cooldown(ratio: float) -> void:
	dash_bar.value = ratio * 100.0


func update_enemies_remaining(count: int) -> void:
	enemies_label.text = "Enemies: %d" % count


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: %d" % new_score


func _on_wave_changed(new_wave: int) -> void:
	wave_label.text = "Wave %d/%d" % [new_wave, GameManager.TOTAL_WAVES]


func show_wave_banner(wave: int) -> void:
	if wave == GameManager.TOTAL_WAVES:
		wave_banner.text = "FINAL WAVE"
	else:
		wave_banner.text = "Wave %d" % wave
	wave_banner.visible = true
	wave_banner.modulate.a = 1.0

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(wave_banner, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): wave_banner.visible = false)
