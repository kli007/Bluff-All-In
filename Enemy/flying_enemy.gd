extends Enemy

var time_passed: float = 0.0
var isAction: State = State.LOOK
var nextAction: State
var targetBody: CharacterBody2D

enum State {FLY, IDLE, LOOK, CHASE, SHOOT, HURT}

@onready var flyTimer: Timer = $FlyingTimer
@onready var stateTimer: Timer = $StateTimer

@export var flying_amplitude: float = 10.0
@export var flying_period: float = 2.0
@export var flying_range: Array
@export var shooting_range: float = 130.0
@export var chasing_range: float = 350.0

var projectile: PackedScene = preload("res://Projectiles/Enemy/FlyEnProj.tscn")

func _ready() -> void:
	super._ready()
	animNode = $AnimationPlayer
	hover_mult = 0.0
	flying_range = [global_position.y - flying_amplitude, 
	global_position.y, global_position.y + flying_amplitude]
	
func set_stats() -> void:
	super.set_stats()
	speed = 50
	max_health = 50
	
func movement(_delta: float) -> void:
	time_passed += _delta
	match isAction:
		State.LOOK:
			animNode.play("FLY")
			lookForPlayer()
		State.FLY:
			animNode.play("FLY")
			flyingAround()
		State.CHASE:
			animNode.play("FLY")
			chasePlayer()
		State.SHOOT:
			if (animNode.current_animation != "SHOOT" and 
			animNode.current_animation != "RELOAD"):
				animNode.play("SHOOT")
		State.IDLE:
			animNode.play("FLY")
			
		State.HURT:
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
		#print("Adjustment: ", adjustment, " Flying Range: ", flying_range)
	else:
		switchIdle(State.LOOK)
		
func lookForPlayer() -> void:
	if targetBody != null:
		switchIdle(State.CHASE)
		return
	if not direction.x:
		direction.x = 1
	else:
		direction *= -1
	switchIdle(State.FLY)
		
func chasePlayer() -> void:
	var targetPosition: Vector2 = targetBody.global_position
	direction = global_position.direction_to(targetPosition)
	if global_position.distance_to(targetPosition) <= shooting_range:
		switchIdle(State.SHOOT)
		return
	elif global_position.distance_to(targetPosition) >= chasing_range:
		targetBody = null
		switchIdle(State.LOOK)
		return
	velocity = direction * speed
	
func shootProj() -> void:
	var Proj = Global.mainNode.get_node("ProjectileGroup")
	var new_projectile = projectile.instantiate()
	direction = global_position.direction_to(targetBody.global_position)
	new_projectile.global_position = global_position
	new_projectile.lock_on_to_player(direction, self)
	Proj.call_deferred("add_child", new_projectile)

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
		shootProj()
		animNode.play("RELOAD")
	if anim_name == "RELOAD":
		switchIdle(State.LOOK)
	if anim_name == "HURT":
		changeState()

func _on_player_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		targetBody = body
		switchIdle(State.CHASE)
		
func unique_hit(damageType: String) -> void:
	super.unique_hit(damageType)
	var tempAction: State = nextAction
	nextAction = State.HURT
	changeState()
	nextAction = tempAction
