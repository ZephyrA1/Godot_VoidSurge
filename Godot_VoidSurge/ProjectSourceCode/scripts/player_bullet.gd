extends Area2D
## Player projectile. Moves in a direction, damages enemies on contact.

var direction: Vector2 = Vector2.RIGHT
var speed: float = 650.0
var damage: float = 10.0
var pierce_remaining: int = 0
var _enemies_hit: Array = []

const LIFETIME: float = 2.0
var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	if _age >= LIFETIME:
		queue_free()

	# Cull if way outside arena
	if position.length() > 1200.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body not in _enemies_hit:
		_enemies_hit.append(body)
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_spawn_hit_particles()
		if pierce_remaining <= 0:
			queue_free()
		else:
			pierce_remaining -= 1


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("arena_walls"):
		queue_free()


func _spawn_hit_particles() -> void:
	# Simple hit flash
	var flash := Sprite2D.new()
	flash.global_position = global_position
	flash.z_index = 5
	flash.modulate = Color.WHITE
	flash.scale = Vector2(0.5, 0.5)

	# Create a small white square texture
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	flash.texture = ImageTexture.create_from_image(img)

	get_tree().current_scene.add_child(flash)
	var tween := flash.create_tween()
	tween.set_parallel(true)
	tween.tween_property(flash, "modulate:a", 0.0, 0.12)
	tween.tween_property(flash, "scale", Vector2(2.0, 2.0), 0.12)
	tween.chain().tween_callback(flash.queue_free)
