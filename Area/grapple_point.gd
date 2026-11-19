extends Entity

var empty_texture = preload("res://Assets/Sprite/Player/emptyprojectile.png")
var hit_texture = preload("res://Assets/Sprite/Player/projectile.png")

@onready var sprite: Sprite2D = $VisualManager/Sprite
@onready var resetTime: Timer = $ResetTimer

func unique_ready() -> void:
	canGrapple = true
	priorityGrapple = true
	grappleType = "PUSH"
	normal_g = 0.0
	gScalar = normal_g
	
	
func takeDamage(damage: float, damageType: String, damagePos: Vector2, origin: CharacterBody2D) -> void:
	if origin.name == "Player":
		CombatManager.enemy_hit.emit(damageType)
		if damageType != "Burn_Grapple":
			deactivate()

func deactivate() -> void:
	canGrapple = false
	sprite.texture = empty_texture
	resetTime.start()
	collision.set_deferred("disabled", true)

func _on_reset_timer_timeout() -> void:
	canGrapple = true
	sprite.texture = hit_texture
	collision.disabled = false

func startHovering() -> void:
	isStatus = STATUS.NOTHING
