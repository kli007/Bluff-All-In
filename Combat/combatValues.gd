class_name CombatValues
extends Resource
	
@export var small_kb: float = 150.0
@export var medium_kb: float = 300.0
@export var large_kb: float = 500.0

@export var player_atk_dmg: float = 15.0
@export var player_proj_dmg: float = 10.0

@export var enemy_small_contact_dmg: float = 6.0
@export var enemy_small_attack_dmg: float = 12.0

@export var hand_HC_dmg: float = 15.0
@export var hand_pair_dmg: float = 16.0
@export var hand_2pair_dmg: float = 34.0
@export var hand_3kind_dmg: float = 45.0
@export var hand_straight_dmg: float = 82.0
@export var hand_flush_dmg: float = 104.0
@export var hand_FH_dmg: float = 116.0
@export var hand_4kind_dmg: float = 218.0
@export var hand_SF_dmg: float = 590.0
@export var hand_RF_dmg: float = 1273.0

@export var s_rank_mult: float = 1.25
@export var a_rank_mult: float = 1.20
@export var b_rank_mult: float = 1.15
@export var c_rank_mult: float = 1.10
@export var d_rank_mult: float = 1.05
@export var f_rank_mult: float = 1.00

@export var s_rank_thres: float = 1600.0
@export var a_rank_thres: float = 900.0
@export var b_rank_thres: float = 400.0
@export var c_rank_thres: float = 250.0
@export var d_rank_thres: float = 75.0

func getKnockback(damageType: String) -> float:
	match damageType:
		"player_atk_dmg", "player_proj_dmg", "hand_HC_dmg", "hand_pair_dmg", "enemy_small_contact_dmg":
			return small_kb
		"enemy_small_attack_dmg", "hand_2pair_dmg", "hand_3kind_dmg", "hand_straight_dmg", "hand_flush_dmg":
			return medium_kb
		_:
			return large_kb
			
func getRankMult(currentValue: float) -> String: 
	if currentValue >= s_rank_thres:
		return "S"
	elif currentValue >= a_rank_thres:
		return "A"
	elif currentValue >= b_rank_thres:
		return "B"
	elif currentValue >= c_rank_thres:
		return "C"
	elif currentValue >= d_rank_thres:
		return "D"
	else:
		return "F"
		
