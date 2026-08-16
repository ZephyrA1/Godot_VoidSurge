extends Camera2D
## Game camera with screen shake support.

var shake_strength: float = 0.0
var shake_decay: float = 0.0
var _shake_timer: float = 0.0


func _process(delta: float) -> void:
	if _shake_timer > 0.0:
		_shake_timer -= delta
		var intensity := shake_strength * (_shake_timer / shake_decay)
		offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
	else:
		offset = offset.move_toward(Vector2.ZERO, 60.0 * delta)


func shake(strength: float, duration: float) -> void:
	shake_strength = strength
	shake_decay = duration
	_shake_timer = duration
