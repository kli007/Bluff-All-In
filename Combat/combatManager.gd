extends Node
var values: CombatValues = preload("res://Combat/combat_values.tres")
var comboMultiplier: float = 0.0
var accumDamage: float
var lastHitEnemy: CharacterBody2D

signal accumDmgChange()
signal enemy_hit(attack_type: String)
signal playerRecoil(direction: Vector2, magnitude: float)

var ATTACKS: Dictionary = {
	"G_Attack_1": _atk("Attack", values.player_atk_dmg, values.min_kb, 1, values.small_recoil),
	"G_Attack_2": _atk("Attack", values.player_atk_dmg, values.min_kb, 1, values.medium_recoil),
	"G_Attack_3": _atk("Attack", values.player_atk_dmg, values.small_kb, 2, 0),
	"Up_Attack":  _atk("Launcher", values.player_launch_dmg, values.launch_kb, 2, 0),
	"Down_Attack":  _atk("Spike", values.player_spike_dmg, values.spike_kb, 4, 0),
	"Dash_Attack": _atk("Attack", values.player_atk_dmg, values.no_kb, 1, 0),
	"Player_Projectile": _atk("Projectile Hit", values.player_proj_dmg, values.no_kb, 1, 0),
	"Burn_Dash": _atk("Burn Dash", 0, values.no_kb, 100, 0),
	"Burn_Grapple": _atk("Burn Grapple", 0, values.no_kb, 100, 0),
	"enemy_small_contact_dmg": _atk("NA", values.enemy_small_contact_dmg, values.small_kb, 3, 0),
	"enemy_small_attack_dmg":  _atk("NA", values.enemy_small_attack_dmg, values.medium_kb, 5, 0),
	"hand_HC_dmg": _atk("High Card", values.hand_HC_dmg, values.small_kb, 3, 0),
	"hand_pair_dmg": _atk("Pair", values.hand_pair_dmg, values.small_kb, 3, 0),
	"hand_2pair_dmg": _atk("Two Pair", values.hand_2pair_dmg, values.medium_kb, 5, 0),
	"hand_3kind_dmg":  _atk("3 of a Kind", values.hand_3kind_dmg, values.medium_kb, 5, 0),
	"hand_straight_dmg": _atk("Straight", values.hand_straight_dmg, values.medium_kb, 7, 0),
	"hand_flush_dmg": _atk("Flush", values.hand_flush_dmg, values.medium_kb, 7, 0),
	"hand_FH_dmg": _atk("Full House", values.hand_FH_dmg, values.large_kb, 7, 0),
	"hand_4kind_dmg": _atk("4 of a Kind", values.hand_4kind_dmg, values.large_kb, 7, 0),
	"hand_SF_dmg":  _atk("Straight Flush", values.hand_SF_dmg, values.large_kb, 7, 0),
	"hand_RF_dmg":  _atk("Royal Flush", values.hand_RF_dmg, values.large_kb, 7, 0),
}

func dealDamage(damageType: String, body: Node, pos: Vector2, origin: String) -> void:
	if not ATTACKS.has(damageType):
		push_error("Unknown attack id: '%s'" % damageType)
		return
	if body.healthNode.checkIfHit(damageType):
		var knockback: Vector2 = ATTACKS[damageType]['knockback']
		var damage: float = ATTACKS[damageType]['damage']
		if origin == "Player":
			if comboMultiplier != 0.0:
				damage *= comboMultiplier
				resetComboMult()
			accumDamage += damage
			accumDmgChange.emit()
		body.takeDamage(damage, knockback, pos, damageType)
		
func recoilBody(attack: String, direction: Vector2, projMag: float) -> void:
	var magnitude: float = ATTACKS[attack]["recoil"]
	if projMag:
		magnitude = projMag
	if magnitude:
		playerRecoil.emit(direction, magnitude)
		
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
	
static func _atk(display: String, damage: float, knockback: Vector2, hit_priority: int, recoil: float) -> Dictionary:
	return {"display": display, "damage": damage, "knockback": knockback, "hit_priority": hit_priority, "recoil": recoil} 
	
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
