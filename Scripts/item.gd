extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": # при соприкосглвении с игроком, монета исчезнет
		player_data.coin += 1
		queue_free()
