extends CanvasLayer
## Displays 3 random upgrade choices between waves. Pauses game while open.

signal upgrade_chosen

@onready var panel: PanelContainer = $CenterContainer/PanelContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/VBoxContainer/TitleLabel
@onready var cards_container: HBoxContainer = $CenterContainer/PanelContainer/VBoxContainer/CardsContainer

var _upgrade_options: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_upgrades() -> void:
	_upgrade_options = GameManager.pick_random_upgrades(3)
	_build_cards()
	visible = true
	get_tree().paused = true


func _build_cards() -> void:
	# Clear old cards
	for child in cards_container.get_children():
		child.queue_free()

	for i in _upgrade_options.size():
		var upgrade := _upgrade_options[i]
		var card := _create_card(upgrade, i)
		cards_container.add_child(card)


func _create_card(upgrade: Dictionary, index: int) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 180)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	style.border_color = upgrade["color"]
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)

	var name_label := Label.new()
	name_label.text = upgrade["name"]
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", upgrade["color"])
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var desc_label := Label.new()
	desc_label.text = upgrade["desc"]
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(desc_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var key_label := Label.new()
	key_label.text = "[%d]" % (index + 1)
	key_label.add_theme_font_size_override("font_size", 18)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(key_label)

	var button := Button.new()
	button.text = "Choose"
	button.pressed.connect(func(): _select_upgrade(index))
	vbox.add_child(button)

	card.add_child(vbox)
	return card


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				if _upgrade_options.size() > 0:
					_select_upgrade(0)
			KEY_2:
				if _upgrade_options.size() > 1:
					_select_upgrade(1)
			KEY_3:
				if _upgrade_options.size() > 2:
					_select_upgrade(2)


func _select_upgrade(index: int) -> void:
	if index < 0 or index >= _upgrade_options.size():
		return

	var upgrade := _upgrade_options[index]
	GameManager.apply_upgrade(upgrade["id"])

	visible = false
	get_tree().paused = false
	upgrade_chosen.emit()
