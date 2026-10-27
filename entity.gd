class_name Entity
extends CharacterBody2D

@onready var effectNode: AnimationPlayer = $EffectsPlayer
@onready var animNode: AnimationPlayer
@onready var healthNode: Node = $HealthManager
@onready var statusTimer: Timer = $StatusTimer
@onready var visNode: Node2D = $VisualManager
@onready var spawnLocation: Vector2 = global_position

@export var speed: float
@export var jump_velocity: float
@export var mass: float
@export var max_health: float
@export var max_hit_threshold: int
@export var invincibility_time: float
@export var hover_mult: float = 0.05
@export var spike_mult: float = 2


var isStatus: STATUS = STATUS.NOTHING

enum STATUS {KNOCKBACK, VERTICAL, HOVER, SPIKE, GRAPPLE, NOTHING}

var statusVelocity: Vector2
var gScalar: float = 1.0
var grappleSpeed: float
var grappleLocation: Vector2
var direction: Vector2
var lastDirection: Vector2 = Vector2.RIGHT

signal hover_change

func _ready() -> void:
	set_stats()
	healthNode.health_empty.connect(death)
	healthNode.setAllValues(max_health, max_hit_threshold, invincibility_time)
	unique_ready()
	
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		gravity(gScalar, delta)
	elif isStatus == STATUS.SPIKE:
		on_status_timer_timeout()
		
	match isStatus:
		STATUS.KNOCKBACK:
			velocity = statusVelocity
		STATUS.VERTICAL:
			velocity = statusVelocity
		STATUS.SPIKE:
			gScalar = spike_mult
		STATUS.HOVER:
			gScalar = hover_mult
		STATUS.GRAPPLE:
			var distance: Vector2 = grappleLocation - global_position
			if distance.length() <= grappleSpeed * delta:
				finishGrapple()
			else:
				velocity = distance.normalized() * grappleSpeed
		STATUS.NOTHING:
			movement(delta)
		
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
		
func takeDamage(damage: float, knockback: Vector2, damagePos: Vector2, damageType: String) -> void:
	if healthNode.takeHit(-damage, damageType):
		if animNode:
			animNode.play("HURT")
		takeKnockback(knockback, damagePos)
		unique_hit(damageType)
		
func takeKnockback(knockForce: Vector2, damagePos: Vector2) -> void:
	if knockForce.x != 0.0:
		var offset: Vector2 = global_position - damagePos
		if is_on_floor():
			offset.y = 0.0
		if offset == Vector2.ZERO:
			offset.x = 1.0
		statusVelocity = offset.normalized() * knockForce.x
		statusTimer.start(0.2)
		isStatus = STATUS.KNOCKBACK
	if knockForce.y != 0.0:
		statusVelocity = knockForce
		statusTimer.start(0.2)
		if statusVelocity.y >= 0:
			isStatus = STATUS.SPIKE
		else:
			isStatus = STATUS.VERTICAL
			
func getGrapple(player: CharacterBody2D, distance: float, gSpeed: float):
	grappleLocation = player.global_position + player.lastDirection * distance 
	grappleSpeed = gSpeed
	isStatus = STATUS.GRAPPLE
	
func finishGrapple() -> void:
	isStatus = STATUS.NOTHING
	velocity = Vector2.ZERO
	takeKnockback(Vector2(CombatManager.values.no_kb), global_position)

func on_status_timer_timeout() -> void:
	velocity = Vector2.ZERO
	gScalar = 1
	if isStatus != STATUS.SPIKE and isStatus != STATUS.HOVER:
		startHovering()
	else:
		isStatus = STATUS.NOTHING

func startHovering() -> void:
	if not is_on_ceiling() and not is_on_floor():
		statusTimer.start(1.0)
		isStatus = STATUS.HOVER
		hover_change.emit()
	else:
		isStatus = STATUS.NOTHING
	
func respawn(new_location: Vector2) -> void:
	global_position = new_location
	healthNode.resetAllValues()
	
func gravity(_scalar: float, _delta: float) -> void:
	velocity += get_gravity() * _delta * _scalar
	
func death() -> void:
	pass
	
func unique_ready() -> void:
	pass
	
func set_stats() -> void:
	pass
	
func unique_hit(damageType: String) -> void:
	pass
	
func _on_hit_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
func movement(delta: float) -> void:
	pass
