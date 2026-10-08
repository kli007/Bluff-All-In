extends Node
var values: CombatValues = preload("res://Combat/combat_values.tres")
var comboMultiplier: float = 0.0
var accumDamage: float

signal accumDmgChange()
signal enemy_hit(attack_type: String)

const HIT_NAMES: Dictionary = {
	"player_atk_dmg": "Attack",
	"player_proj_dmg": "Projectile Hit",
	"hand_HC_dmg": "High Card",
	"hand_pair_dmg": "Pair",
	"hand_2pair_dmg": "Two Pair",
	"hand_3kind_dmg": "3 of a Kind",
	"hand_straight_dmg": "Straight",
	"hand_flush_dmg": "Flush",
	"hand_FH_dmg": "Full House",
	"hand_4kind_dmg": "4 of a Kind",
	"hand_SF_dmg": "Straight Flush",
	"hand_RF_dmg": "Royal Flush",
}

func dealDamage(damageType: String, body: Node, pos: Vector2, origin: String) -> void:
	if not body.healthNode.isInvincible or body.healthNode.checkIfHit(damageType):
		var knockback: float = values.getKnockback(damageType)
		var damage: float = values.get(damageType)
		if origin == "Player":
			if comboMultiplier != 0.0:
				damage *= comboMultiplier
				resetComboMult()
			accumDamage += damage
			accumDmgChange.emit()
		body.takeDamage(damage, knockback, pos, damageType)

		
func _checkInValues(checkName: String) -> void:
	print(checkName)
	if values.get(checkName) != null:
		print("Yes, is working in values")
	else:
		print("No, something has gone wrong")
		
		
func setComboMultiplier(comboChain: float) -> void:
	comboMultiplier = 1.0 + comboChain/100.0
	
func resetComboMult() -> void:
	comboMultiplier = 0.0

func resetAccumDmg() -> void:
	accumDamage = 0.0
	
func getRankText() -> String:
	return values.getRankMult(accumDamage)
	
func getAttackPriority(attack: String) -> int:
	match attack:
		"player_atk_dmg", "player_proj_dmg":
			return 1
		"hand_HC_dmg", "hand_pair_dmg", "enemy_small_contact_dmg":
			return 3
		"enemy_small_attack_dmg", "hand_2pair_dmg", "hand_3kind_dmg":
			return 5
		_:
			return 7
	
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
