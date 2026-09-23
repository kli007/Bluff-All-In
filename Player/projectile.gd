extends Area2D

const DAMAGE: float = 10.0
const SPEED: float = 350.0

var direction: Vector2
var player: Node2D
var projNode: Node
var exceptionArray: Array

func _ready() -> void:
	exceptionArray.append(player)
	'''for proj in projNode.get_children():
		exceptionArray.append(proj) #may not be necessary? projectiles are all area 2d
'''
func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func lock_on_to_player(player_dir: Vector2, playerNode:Node2D, projectileNode:Node):
	direction = player_dir
	player = playerNode
	projNode = projectileNode
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if exceptionArray.has(body):
		return
	elif body is CharacterBody2D:
		body.takeDamage(DAMAGE, 0, Vector2(0,0))
		queue_free()
