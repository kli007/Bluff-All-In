extends Enemy

var time_passed: float = 0.0
var isAction: State = State.LOOK
var nextAction: State

enum State {FLY, IDLE, LOOK, CHASE, SHOOT}

@onready var flyTimer: Timer = $FlyingTimer
@onready var stateTimer: Timer = $StateTimer

@export var flying_amplitude: float = 10.0
@export var flying_period: float = 2.0
@export var flying_range: Array

func _ready() -> void:
	super._ready()
	hover_mult = 0.0
	flying_range = [global_position.y - flying_amplitude, 
	global_position.y, global_position.y + flying_amplitude]
	
func set_stats() -> void:
	super.set_stats()
	speed = 50
	max_health = 5000

func movement(_delta: float) -> void:
	time_passed += _delta
	match isAction:
		State.LOOK:
			if not direction.x:
				direction.x = 1
			else:
				direction *= -1
				switchIdle(State.FLY)
		State.FLY:
			flyingAround()
		State.CHASE:
			pass
		State.SHOOT:
			pass
		State.IDLE:
			pass
	
	
func gravity(_scalar: float, _delta: float) -> void:
	pass
	
func flyingAround() -> void:
	var adjustment: float = 0.0
	if flyTimer.is_stopped():
		flyTimer.start(randf_range(2.5, 5.5))
		
	if global_position.y < flying_range[0] or global_position.y > flying_range[2]:
		adjustment = flying_range[1] - global_position.y
		
	if not is_on_wall():
		velocity.x = direction.x * speed
		velocity.y = sin(time_passed * flying_period) * flying_amplitude + adjustment
		print("Adjustment: ", adjustment, " Flying Range: ", flying_range)
	else:
		switchIdle(State.LOOK)

func switchIdle(placeHolder: State = State.LOOK) -> void:
	nextAction = State.IDLE
	changeState()
	stateTimer.start(1.0)
	nextAction = placeHolder
	
func changeState() -> void:
	velocity.x = 0
	velocity.y = 0
	stateTimer.stop()
	flyTimer.stop()
	isAction = nextAction
	
func _on_flying_timer_timeout() -> void:
	switchIdle(State.LOOK)

func _on_state_timer_timeout() -> void:
	changeState()
