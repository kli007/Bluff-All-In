extends Entity

func unique_ready() -> void:
	canGrapple = true
	priorityGrapple = true
	grappleType = "PUSH"
	normal_g = 0.0
	gScalar = normal_g
	
func takeDamage(damage: float, knockback: Vector2, damagePos: Vector2, damageType: String) -> void:
	if damageType == "Burn_Grapple":
		CombatManager.enemy_hit.emit(damageType)

func takeKnockback(knockForce: Vector2, damagePos: Vector2) -> void:
	pass
	
