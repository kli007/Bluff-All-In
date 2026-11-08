extends Entity

func unique_ready() -> void:
	canGrapple = true
	priorityGrapple = true
	grappleType = "PUSH"
	normal_g = 0.0
	gScalar = normal_g
	
func takeDamage(damage: float, damageType: String, damagePos: Vector2, origin: CharacterBody2D) -> void:
	if damageType == "Burn_Grapple":
		CombatManager.enemy_hit.emit(damageType)

func takeKnockback(knockForce: Vector2, damagePos: Vector2, origin: CharacterBody2D) -> void:
	pass
	
