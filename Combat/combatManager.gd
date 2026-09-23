extends Node

var values: CombatValues = preload("res://Combat/combat_values.tres")

func dealDamage(damageType: String, knockbackType: String, body: Node, pos: Vector2) -> void:
	var knockback: float = values.get(knockbackType) 
	var damage: float = values.get(damageType)
	body.takeDamage(damage, knockback, pos)

func checkInValues(checkName: String) -> void:
	print(checkName)
	if values.get(checkName) != null:
		print("Yes, is working in values")
	else:
		print("No, something has gone wrong")
