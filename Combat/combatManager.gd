extends Node
var values: CombatValues = preload("res://Combat/combat_values.tres")
var comboMultiplier: float = 0.0
var accumDamage: float

signal accumDmgChange()
signal enemy_hit(attack_type: String)

var ATTACKS: Dictionary = {
	"player_atk_dmg":          _atk("Attack",         values.no_kb,     1),
	"player_proj_dmg":         _atk("Projectile Hit", values.no_kb,  1),
	"player_launch_dmg":       _atk("Launcher",       values.launch_kb, 2),
	"player_spike_dmg":        _atk("Spike",          values.spike_kb,  4),
	"enemy_small_contact_dmg": _atk("NA",             values.small_kb,  3),
	"enemy_small_attack_dmg":  _atk("NA",             values.medium_kb, 5),
	"hand_HC_dmg":             _atk("High Card",      values.small_kb,  3),
	"hand_pair_dmg":           _atk("Pair",           values.small_kb,  3),
	"hand_2pair_dmg":          _atk("Two Pair",       values.medium_kb, 5),
	"hand_3kind_dmg":          _atk("3 of a Kind",    values.medium_kb, 5),
	"hand_straight_dmg":       _atk("Straight",       values.medium_kb, 7),
	"hand_flush_dmg":          _atk("Flush",          values.medium_kb, 7),
	"hand_FH_dmg":             _atk("Full House",     values.large_kb,  7),
	"hand_4kind_dmg":          _atk("4 of a Kind",    values.large_kb,  7),
	"hand_SF_dmg":             _atk("Straight Flush", values.large_kb,  7),
	"hand_RF_dmg":             _atk("Royal Flush",    values.large_kb,  7),
}

func dealDamage(damageType: String, body: Node, pos: Vector2, origin: String) -> void:
	if not body.healthNode.isInvincible or body.healthNode.checkIfHit(damageType):
		var knockback: Vector2 = ATTACKS[damageType]['knockback']
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
	
static func _atk(display: String, knockback: Vector2, hit_priority: int) -> Dictionary:
	return {"display": display, "knockback": knockback, "hit_priority": hit_priority} 
	
func getRankText() -> String: 
	if accumDamage >= values.s_rank_thres:
		return "S"
	elif accumDamage >= values.a_rank_thres:
		return "A"
	elif accumDamage >= values.b_rank_thres:
		return "B"
	elif accumDamage >= values.c_rank_thres:
		return "C"
	elif accumDamage >= values.d_rank_thres:
		return "D"
	else:
		return "F"
		
	
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
