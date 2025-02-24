extends CanvasLayer

const HEART_ROW_SIZE = 8
const HEART_OFFSET = 16

func _ready() -> void:
	# рисуем жизнь в виде сердечек
	for i in player_data.life:
		var new_heart = Sprite2D.new()
		new_heart.texture = $player_life.texture
		new_heart.hframes = $player_life.hframes
		$player_life.add_child(new_heart)

func _process(delta: float) -> void:
	$coin_num.text = var_to_str (player_data.coin)
	display_heart()

func display_heart():
	# убавляем сердечки
	for heart in $player_life.get_children():
		var index = heart.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		heart.position = Vector2(x, y)
		
		var last_heart = floor(player_data.life)
		if index > last_heart:
			heart.frame = 0
		if index == last_heart:
			heart.frame = (player_data.life - last_heart) * 4
		if index < last_heart:
			heart.frame = 4
			
