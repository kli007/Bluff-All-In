extends CharacterBody2D

var damage
var speed: float = 350.0

var direction: float
var player: Node2D
var projNode: Node

func _ready():
	add_collision_exception_with(player)

func _process(_delta: float):
	for proj in projNode.get_children():
		add_collision_exception_with(proj)
		
	velocity.x = direction * speed
	move_and_slide()
	for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if(collision.get_collider().has_method("decrementHealth")):
				var _target = collision.get_collider()
				#target.decrementHealth(damage)
				#target.knockback(direction, 500, 0.1) 
			queue_free()

func lock_on_to_player(player_dir: float, playerNode:Node2D, projectileNode:Node):
	direction = player_dir
	player = playerNode
	projNode = projectileNode
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#print('removed')
	queue_free()
