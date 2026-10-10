class_name Entity
extends CharacterBody2D

@onready var effectNode: AnimationPlayer = $EffectsPlayer
@onready var healthNode: Node = $HealthManager
@onready var knockTimer: Timer = $KnockbackTimer
@onready var visNode: Node2D = $VisualManager
@onready var spawnLocation: Vector2 = global_position

@export var speed: float
@export var jump_velocity: float
@export var max_health: float
@export var max_hit_threshold: int
@export var invincibility_time: float

var isKnockback: bool = false
var knockbackVelocity: Vector2
var direction: Vector2
var lastDirection: Vector2 = Vector2.RIGHT

func _ready() -> void:
	set_stats()
	healthNode.invincibility_started.connect(func() -> void: effectNode.play('Invincible'))
	healthNode.invincibility_ended.connect(func() -> void: effectNode.play('RESET'))
	healthNode.health_empty.connect(death)
	healthNode.setAllValues(max_health, max_hit_threshold, invincibility_time)
	unique_ready()
	
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if isKnockback:
		velocity.x = knockbackVelocity.x
	else:
		movement(delta)
		
	flip_sprite()
	move_and_slide()
	
func movement(delta: float) -> void:
	pass
	
func flip_sprite() -> void:
	if direction.x < 0:
		visNode.scale.x = -1
	if direction.x > 0:
		visNode.scale.x = 1
		
func takeDamage(damage: float, knockback: Vector2, damagePos: Vector2, damageType: String) -> void:
	if healthNode.takeHit(-damage, damageType):
		takeKnockback(knockback, damagePos)
		unique_hit(damageType)
		
func takeKnockback(knockForce: Vector2, damagePos: Vector2) -> void:
	var knockbackDir = (global_position - damagePos).normalized()
	knockbackVelocity = knockbackDir * knockForce.x
	knockTimer.start()
	isKnockback = true

func _on_knockback_timer_timeout() -> void:
	velocity.x = 0
	isKnockback = false
	
func respawn(new_location: Vector2) -> void:
	global_position = new_location
	healthNode.resetAllValues()
	
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
