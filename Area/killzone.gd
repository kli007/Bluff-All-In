extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.get_node('HealthManager').changeHealth(-50.0)
		body.respawn(body.spawnLocation)
