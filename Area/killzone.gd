extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.healthNode.changeHealth(-50.0)
		body.respawn(body.spawnLocation)
	elif body.is_class("CharacterBody2D"):
		body.queue_free()
