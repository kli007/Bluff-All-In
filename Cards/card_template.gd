extends Node

var suit: String = ''
var rank: String = ''

func setData(inSuit, inRank) -> void:
	suit = inSuit
	rank = inRank
	
func resetData() -> void:
	suit = ''
	rank = ''
	
func checkData() -> bool:
	if rank == '' and suit == '':
		return true
	else:
		return false
