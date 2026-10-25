extends Area2D

const SPEED: float = 250.0

var direction: Vector2
var parentNode: CharacterBody2D

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func lock_on_to_player(player_dir: Vector2, parent: CharacterBody2D) -> void:
	direction = player_dir
	parentNode = parent
	rotation = direction.angle()
	
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == parentNode:
		return
	if body.name == "Player":
		CombatManager.dealDamage('player_proj_dmg', body, global_position, "")
	queue_free()
