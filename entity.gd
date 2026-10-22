class_name Entity
extends CharacterBody2D

@onready var effectNode: AnimationPlayer = $EffectsPlayer
@onready var healthNode: Node = $HealthManager
@onready var knockTimer: Timer = $KnockbackTimer
@onready var hoverTimer: Timer = $HoverTimer
@onready var vertTimer: Timer = $VerticalTimer
@onready var visNode: Node2D = $VisualManager
@onready var spawnLocation: Vector2 = global_position

@export var speed: float
@export var jump_velocity: float
@export var max_health: float
@export var max_hit_threshold: int
@export var invincibility_time: float
@export var hover_mult: float = 0.05

var isKnockback: bool = false
var isVertical: bool = false
var isHovering: bool = false
var isSpiked: bool = false
var knockbackVelocity: Vector2
var verticalVelocity: Vector2
var direction: Vector2
var lastDirection: Vector2 = Vector2.RIGHT

signal hover_change

func _ready() -> void:
	set_stats()
	healthNode.health_empty.connect(death)
	healthNode.setAllValues(max_health, max_hit_threshold, invincibility_time)
	unique_ready()
	
	
func _physics_process(delta: float) -> void:
	var hoverScalar: float = 1
	if isHovering:
		hoverScalar = hover_mult
	if not is_on_floor():
		gravity(hoverScalar, delta)
	else:
		isSpiked = false
	if isVertical or isKnockback or isHovering:
		if isVertical:
			velocity = verticalVelocity
		if isKnockback:
			velocity = knockbackVelocity
	else:
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
		effectNode.play("HURT")
		takeKnockback(knockback, damagePos)
		unique_hit(damageType)
		
func takeKnockback(knockForce: Vector2, damagePos: Vector2) -> void:
	if knockForce.x != 0.0:
		var offset: Vector2 = global_position - damagePos
		if is_on_floor():
			offset.y = 0.0
		if offset == Vector2.ZERO:
			offset.x = 1.0
		knockbackVelocity = offset.normalized() * knockForce.x
		knockTimer.start()
		isKnockback = true
	if knockForce.y != 0.0:
		verticalVelocity = knockForce
		vertTimer.start()
		isVertical = true
		if verticalVelocity.y >= 0:
			isSpiked = true
	

func _on_knockback_timer_timeout() -> void:
	velocity.x = 0.0
	isKnockback = false

func _on_vertical_timer_timeout() -> void:
	velocity.y =  0.0
	isVertical = false
	startHovering()
	
func _on_hover_timer_timeout() -> void:
	isHovering = false
	
func startHovering() -> void:
	if not is_on_ceiling() and not is_on_floor() and not isSpiked:
		hoverTimer.start()
		isHovering = true
		hover_change.emit()
	
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
