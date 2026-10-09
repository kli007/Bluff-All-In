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
var lastDirection: Vector2

func _ready() -> void:
	healthNode.invincibility_started.connect(func() -> void: effectNode.play('Invincible'))
	healthNode.invincibility_ended.connect(func() -> void: effectNode.play('RESET'))
	
	
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
		
func takeDamage(damage: float, knockback: Vector2, playerPos: Vector2, damageType: String) -> void:
	if healthNode.takeHit(-damage, damageType):
		CombatManager.enemy_hit.emit(CombatManager.HIT_NAMES[damageType])
		takeKnockback(knockback, playerPos)
		
func takeKnockback(knockForce: Vector2, playerPos: Vector2) -> void:
	var knockbackDir = (global_position - playerPos).normalized()
	knockbackVelocity = knockbackDir * knockForce.x
	knockTimer.start()
	isKnockback = true

func _on_knockback_timer_timeout() -> void:
	velocity.x = 0
	isKnockback = false
	
func respawn(new_location: Vector2) -> void:
	global_position = new_location
	healthNode.resetAllValues()
	
	
	
