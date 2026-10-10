extends Enemy

enum State {IDLE, WALK, CHARGE, LOOK}

@export var charge_speed: float = 200.0
@export var charge_damage: String = "enemy_small_attack_dmg"
@export var charge_distance: float = 150.0

@onready var floorRay: RayCast2D = $VisualManager/FloorRay
@onready var playerRay: ShapeCast2D = $VisualManager/PlayerRay
@onready var stateTimer: Timer = $StateTimer
@onready var walkTimer: Timer = $WalkTimer
@onready var lookTimer: Timer = $LookTimer

var isAction: State = State.LOOK
var nextAction: State
var lookingCounter: int = 0
var targetPosition: float

func _ready() -> void:
	super._ready()
	playerRay.add_exception(self)
	
func set_stats() -> void:
	super.set_stats()
	speed = 50
	max_health = 50

func movement(_delta: float) -> void:
	match isAction:
		State.CHARGE:
			chargePlayer()
		State.LOOK:
			lookForPlayer()
			detectPlayer()
		State.WALK:
			walkingAround()
		State.IDLE:
			pass

func walkingAround() -> void:
	if walkTimer.is_stopped():
		walkTimer.start(randf_range(2.5, 5.5))
		
	if floorRay.is_colliding() and not is_on_wall():
		velocity.x = direction.x * speed
	else:
		switchIdle(State.LOOK)

func lookForPlayer() -> void:
	if not direction.x:
		direction.x = 1
	if lookingCounter < 3 and lookTimer.is_stopped():
		lookTimer.start()
	elif lookingCounter == 3:
		switchIdle(State.WALK)

func changeState() -> void:
	velocity.x = 0
	lookingCounter = 0
	stateTimer.stop()
	walkTimer.stop()
	lookTimer.stop()
	isAction = nextAction
	
func detectPlayer() -> void:
	if playerRay.is_colliding() and floorRay.is_colliding():
		var hitObject: Node = playerRay.get_collider(0)
		if hitObject.name == 'Player':
			targetPlayer()
			
func targetPlayer() -> void:
	if stateTimer.is_stopped():
		targetPosition = global_position.x + (direction.x * charge_distance)
		switchIdle(State.CHARGE)
		
func chargePlayer() -> void:
	velocity.x = direction.x * charge_speed
	var remaining_distance: float = (targetPosition - global_position.x) * direction.x
	if remaining_distance <= 0.0 or is_on_wall():
		switchIdle(State.LOOK)
	
func switchIdle(placeHolder: State) -> void:
	nextAction = State.IDLE
	changeState()
	stateTimer.start(1.0)
	nextAction = placeHolder
		
func _on_state_timer_timeout() -> void:
	changeState()

func _on_look_timer_timeout() -> void:
	direction.x *= -1
	lookingCounter += 1
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	var damageType: String
	match isAction:
		State.CHARGE:
			damageType = charge_damage
		_:
			damageType = contact_damage
	if body.name == "Player":
		CombatManager.dealDamage(damageType, body, global_position, self.name)


func _on_walk_timer_timeout() -> void:
	switchIdle(State.LOOK)
	
