extends Enemy

enum State {IDLE, WALK, CHARGE, LOOK}

@export var charge_speed: float = 400.0
@export var charge_damage: String

@onready var floorRay: Node = $VisualManager/FloorRay
@onready var walkTimer: Timer = $WalkTimer
@onready var delayTimer: Timer = $DelayTimer
@onready var lookTimer: Timer = $LookTimer

var isAction: State = State.IDLE
var lookingCounter: int = 0

func _ready() -> void:
	speed = 50
	max_health = 50
	startHealth()

func movement() -> void:
	match isAction:
		State.CHARGE:
			pass
		State.LOOK:
			lookForPlayer()
		State.WALK:
			if floorRay.is_colliding():
				velocity.x = direction.x * speed
			else:
				changeState(State.IDLE)
		State.IDLE:
			velocity.x = 0
			if delayTimer.is_stopped():
				delayTimer.start()
	
func startWalkTimer() -> void:
	walkTimer.wait_time = randf_range(2.5, 5.5)
	print(walkTimer.wait_time)
	walkTimer.start()
	changeState(State.WALK)
	
func lookForPlayer() -> void:
	if not direction.x:
		direction.x = 1
	if lookingCounter < 3 and lookTimer.is_stopped():
		lookTimer.start()
	elif lookingCounter == 3:
		startWalkTimer()

func changeState(newState: State) -> void:
	lookingCounter = 0
	walkTimer.stop()
	delayTimer.stop()
	lookTimer.stop()
	isAction = newState
	
func _on_walk_timer_timeout() -> void:
	velocity.x = 0
	changeState(State.IDLE)

func _on_delay_timer_timeout() -> void:
	changeState(State.LOOK)

func _on_look_timer_timeout() -> void:
	direction.x *= -1
	lookingCounter += 1
