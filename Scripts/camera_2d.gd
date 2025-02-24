extends Camera2D

@onready var player = $"../Player"
@export var camera: camera_states
enum camera_states {FOLLOW, PANNING}

func _process(delta):
	match camera:
		camera_states.FOLLOW:
			camera_follow()
		camera_states.PANNING:
			camera_panning()

# функция перемещения камеры с уровня на уровень
func camera_panning():
	anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	position = player.position
	var x = floor(position.x / 320) * 320
	var y = floor(position.y / 180) * 180

	position = Vector2(x,y)
	
	# линейная интерполяция, для более гладкого перехода камеры
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", Vector2(x,y), 0.14)

func camera_follow():
	anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER
	position = player.position
