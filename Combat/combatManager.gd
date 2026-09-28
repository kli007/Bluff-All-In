extends Node
var values: CombatValues = preload("res://Combat/combat_values.tres")
var comboMultiplier: float = 0.0
var accumDamage: float

signal accumDmgChange

func dealDamage(damageType: String, body: Node, pos: Vector2) -> void:
	var knockback: float = values.getKnockback(damageType)
	var damage: float = values.get(damageType)
	if comboMultiplier != 0.0:
		damage *= comboMultiplier
		comboMultiplier = 0.0
	body.takeDamage(damage, knockback, pos)
	accumDamage += damage
	accumDmgChange.emit()

func checkInValues(checkName: String) -> void:
	print(checkName)
	if values.get(checkName) != null:
		print("Yes, is working in values")
	else:
		print("No, something has gone wrong")
		
func setComboMultiplier(comboChain: float) -> void:
	comboMultiplier = 1.0 + comboChain/100.0
	
func resetAccumDmg() -> void:
	accumDamage = 0.0
	
func getRankText() -> String:
	return values.getRankMult(accumDamage)
	
func getRankMultiplier(rank: String) -> float:
	match rank:
		"S":
			return values.s_rank_mult
		"A":
			return values.a_rank_mult
		"B":
			return values.b_rank_mult
		"C":
			return values.c_rank_mult
		"D":
			return values.d_rank_mult
		_:
			return values.f_rank_mult
