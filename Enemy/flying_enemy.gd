extends Enemy

var time_passed: float = 0.0
var isAction: State = State.LOOK
var nextAction: State
var targetBody: CharacterBody2D

enum State {FLY, IDLE, LOOK, CHASE, SHOOT, HURT}

@onready var flyTimer: Timer = $FlyingTimer
@onready var stateTimer: Timer = $StateTimer
@onready var animNode: AnimationPlayer = $AnimationPlayer

@export var flying_amplitude: float = 10.0
@export var flying_period: float = 2.0
@export var flying_range: Array
@export var shooting_range: float = 150.0

func _ready() -> void:
	super._ready()
	hover_mult = 0.0
	flying_range = [global_position.y - flying_amplitude, 
	global_position.y, global_position.y + flying_amplitude]
	
func set_stats() -> void:
	super.set_stats()
	speed = 50
	max_health = 5000
	
func _physics_process(delta: float) -> void:
	time_passed += delta
	super._physics_process(delta)
	animation_control()

func movement(_delta: float) -> void:
	if Input.is_action_just_pressed("Look_Down"):
		switchIdle(State.SHOOT)
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
			chasePlayer()
		State.SHOOT:
			pass
		State.IDLE:
			pass
			
			
func animation_control() -> void:
	if isAction == State.HURT:
		animNode.play("SHOOT")
	elif isAction == State.SHOOT:
		animNode.play("SHOOT")
	else:
		animNode.play("FLY")
	
	
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
		#print("Adjustment: ", adjustment, " Flying Range: ", flying_range)
	else:
		switchIdle(State.LOOK)
		
func chasePlayer() -> void:
	var targetPosition: Vector2 = targetBody.global_position
	direction = global_position.direction_to(targetPosition)
	#print(global_position.distance_to(targetPosition))
	if global_position.distance_to(targetPosition) <= shooting_range:
		switchIdle(State.SHOOT)
		return
	velocity = direction * speed

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


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "SHOOT":
		switchIdle(State.LOOK)


func _on_player_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		targetBody = body
		switchIdle(State.CHASE)
