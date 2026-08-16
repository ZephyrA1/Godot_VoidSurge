extends Area2D
## Enemy projectile. Moves in a direction, damages the player on contact.

var direction: Vector2 = Vector2.RIGHT
var speed: float = 320.0
var damage: float = 8.0

const LIFETIME: float = 4.0
var _age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_age += delta
	if _age >= LIFETIME or position.length() > 1200.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
