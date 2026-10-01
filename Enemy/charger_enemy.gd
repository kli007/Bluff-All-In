extends Enemy

@export var charge_speed: float = 400.0
@export var charge_damage: String

@onready var floorCheck: Node = $VisualManager/FloorRay
@onready var walkTimer: Timer = $WalkTimer

var isAction: String 

func _ready() -> void:
	speed = 50
	max_health = 50
	startHealth()

func movement() -> void:
	if floorCheck.is_colliding() and isAction == 'Walking':
		velocity.x = direction.x * speed
	else:
		velocity.x = 0
		startWalkTimer()
	
func startWalkTimer() -> void:
	await 1.0
	if direction.x:
		direction.x *= -1
	else:
		direction.x = 1
	walkTimer.wait_time = randf_range(2.5, 5.5)
	walkTimer.start()
	isAction = 'Walking'
	
	
func _on_walk_timer_timeout() -> void:
	velocity.x = 0
	isAction = ''
