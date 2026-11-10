class_name Entity
extends CharacterBody2D

@onready var effectNode: AnimationPlayer = $EffectsPlayer
@onready var animNode: AnimationPlayer
@onready var healthNode: Node = $HealthManager
@onready var statusTimer: Timer = $StatusTimer
@onready var visNode: Node2D = $VisualManager
@onready var groundRay: RayCast2D = $GroundRay
@onready var spawnLocation: Vector2 = global_position

@export var speed: float
@export var acceleration: float
@export var jump_velocity: float
@export var max_health: float
@export var max_hit_threshold: int
@export var invincibility_time: float
@export var hover_mult: float = 0.05
@export var max_hover_fall: float = 15.0
@export var spike_mult: float = 2
@export var normal_g: float = 1.0
@export var canGrapple: bool = true
@export var priorityGrapple: bool = false

var isStatus: STATUS = STATUS.NOTHING

enum STATUS {KNOCKBACK, HOVER, DRAG, GRAPPLE, RECOIL, NOTHING}

var statusVelocity: Vector2
var gScalar: float = normal_g
var grappleSpeed: float
var grappleLocation: Vector2
var direction: Vector2
var lastDirection: Vector2 = Vector2.RIGHT
var grappleType: String = "PULL"
var dragBody: CharacterBody2D 

signal hover_change
signal grapple_signal

func _ready() -> void:
	set_stats()
	healthNode.health_empty.connect(death)
	healthNode.setAllValues(max_health, max_hit_threshold, invincibility_time)
	unique_ready()
	
	
func _physics_process(delta: float) -> void:
	physics(delta)
	checkStatus(delta)
	moveHelper()
	
func physics(delta: float) -> void:
	var friction: float
	if not is_on_floor():
		velocity += get_gravity() * delta * gScalar
		friction = Global.air_friction
	elif "friction" in groundRay.get_collider():
		friction = groundRay.get_collider().friction
	if not direction:
		velocity.x = move_toward(velocity.x, 0, friction)
	
func checkStatus(delta: float) -> void:
	match isStatus:
		STATUS.KNOCKBACK:
			velocity = statusVelocity
		STATUS.DRAG:
			velocity.y = dragBody.velocity.y
		STATUS.HOVER:
			gScalar = hover_mult
			velocity.y = minf(velocity.y, max_hover_fall)
			hoverMovement(delta)
		STATUS.GRAPPLE:
			if grappleType == "PULL":
				var distance: Vector2 = grappleLocation - global_position
				if distance.length() <= grappleSpeed * delta:
					finishGrapple()
				else:
					velocity = distance.normalized() * grappleSpeed
			else:
				velocity = Vector2.ZERO
		STATUS.RECOIL:
			velocity = statusVelocity
		STATUS.NOTHING:
			movement(delta)
	
func moveHelper() -> void:
	flip_sprite()
	move_and_slide()
	effect_control()
	
func effect_control() -> void:
	if not effectNode.is_playing():
		if healthNode.isInvincible:
			effectNode.play("Invincible")
	
func flip_sprite() -> void:
	if direction.x < 0:
		visNode.scale.x = -1
	if direction.x > 0:
		visNode.scale.x = 1
		
func takeDamage(damage: float, damageType: String, damagePos: Vector2, origin: CharacterBody2D) -> void:
	var knockback: Vector2 = CombatManager.ATTACKS[damageType]['knockback']
	if healthNode.takeHit(-damage, damageType):
		if animNode:
			animNode.play("HURT")
		takeKnockback(knockback, damagePos, origin)
		unique_hit(damageType, damagePos)
		
func takeKnockback(knockForce: Vector2, damagePos: Vector2, origin: CharacterBody2D) -> void:
	if knockForce.x != 0.0:
		var offset: Vector2 = global_position - damagePos
		if is_on_floor():
			offset.y = 0.0
		if offset == Vector2.ZERO:
			offset.x = 1.0
		statusVelocity = offset.normalized() * knockForce.x
		statusTimer.start(0.2)
		isStatus = STATUS.KNOCKBACK
	elif knockForce.y != 0.0:
		on_status_timer_timeout()
		dragBody = origin
		isStatus = STATUS.DRAG
		add_collision_exception_with(dragBody)
		dragBody.add_collision_exception_with(self)
		dragBody.dragFinished.connect(on_status_timer_timeout, CONNECT_ONE_SHOT)
		'statusVelocity = knockForce
		statusTimer.start(0.2)
		if statusVelocity.y >= 0:
			isStatus = STATUS.SPIKE
		else:
			isStatus = STATUS.VERTICAL'
			
func getGrapple(source: CharacterBody2D, distance: float, gSpeed: float):
	if grappleType == "PULL":
		grappleLocation = source.global_position + source.lastDirection * distance 
		grappleSpeed = gSpeed
	elif grappleType == "PUSH":
		lastDirection = -source.lastDirection
		source.getGrapple(self, distance, gSpeed)
		source.grapple_signal.connect(finishGrapple, CONNECT_ONE_SHOT)
	isStatus = STATUS.GRAPPLE
	
func finishGrapple() -> void:
	isStatus = STATUS.NOTHING
	velocity = Vector2.ZERO
	startHovering()
	grapple_signal.emit()
	
func startRecoil(damagePos: Vector2, magnitude: float) -> void:
	statusVelocity = damagePos.normalized() * magnitude
	if is_on_floor():
		statusVelocity = Vector2(statusVelocity.x, 0)
	statusTimer.start(0.1)
	isStatus = STATUS.RECOIL

func on_status_timer_timeout() -> void:
	velocity = Vector2.ZERO
	gScalar = normal_g
	if dragBody != null:
		remove_collision_exception_with(dragBody)
		dragBody.remove_collision_exception_with(self)
		dragBody.startHovering()
		dragBody = null
	if not isStatus in [STATUS.HOVER, STATUS.RECOIL]:
		startHovering()
	else:
		isStatus = STATUS.NOTHING

func startHovering() -> void:
	if not is_on_ceiling() and not is_on_floor():
		velocity.y = 0.0
		gScalar = hover_mult
		statusTimer.start(0.5)
		isStatus = STATUS.HOVER
		hover_change.emit()
	else:
		isStatus = STATUS.NOTHING
	
func respawn(new_location: Vector2) -> void:
	global_position = new_location
	healthNode.resetAllValues()
	
func death() -> void:
	pass
	
func unique_ready() -> void:
	pass
	
func set_stats() -> void:
	pass
	
func unique_hit(damageType: String, damagePos: Vector2) -> void:
	pass
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
func movement(delta: float) -> void:
	pass
	
func hoverMovement(delta: float) -> void:
	pass
