extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 300

@onready var hLabel = $HealthControl/HealthLabel
@onready var health = $HealthManager
@onready var knockTimer = $KnockbackTimer

var isKnockback: bool = false
var knockbackVelocity: Vector2

func _ready() -> void:
	health.health_changed.connect(_on_enemy_health_changed)
	health.setMaxHealth(MAX_HEALTH)
	hLabel.text = str("Health: ", MAX_HEALTH)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if isKnockback:
		velocity.x = knockbackVelocity.x
	else:
		movement()
		
	move_and_slide()
	
func _on_enemy_health_changed() -> void:
	hLabel.text = str("Health: ", health.health)
	
func takeDamage(damage: float, knockback: float, playerPos: Vector2) -> void:
	health.changeHealth(-damage)
	takeKnockback(knockback, playerPos)
	
func takeKnockback(knockForce: float, playerPos: Vector2) -> void:
	var knockbackDir = (global_position - playerPos).normalized()
	knockbackVelocity = knockbackDir * knockForce
	knockTimer.start()
	isKnockback = true

func _on_knockback_timer_timeout() -> void:
	velocity.x = 0
	isKnockback = false
	
func movement() -> void:
	return
