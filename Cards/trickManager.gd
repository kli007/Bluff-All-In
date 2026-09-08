extends Node

const RANKMAX: int = 12
const RANKMIN: int = 0
const SUITEND: int = 3
const SUITBEG: int = 0

func mainManager(cardNode: Node, rankTrick: String, suitTrick: String) -> void:
	var cardRank: String = cardNode.rank
	var cardSuit: String = cardNode.suit
	
	var newRank: String = cardRank
	var newSuit: String = cardSuit
	if rankTrick:
		newRank = changeRank(cardRank, rankTrick)
	if suitTrick:
		newSuit = changeSuit(cardSuit, suitTrick)
		
	cardNode.setData(newSuit, newRank)
	CardData.changeCardSprite(cardNode)
	
func changeRank(current: String, trick: String) -> String:
	var key: int = CardData.ranks.find(current)
	var returnRank: String = current
	match(trick):
		'Increase':
			if key < RANKMAX:
				returnRank = CardData.ranks[key + 1]
		'Decrease':
			if key > RANKMIN: 
				returnRank = CardData.ranks[key - 1]
	return(returnRank)
	
func changeSuit(current: String, trick: String) -> String:
	var key: int = CardData.suits.find(current)
	var returnSuit: String = current
	match(trick):
		'Right':
			if CardData.suits[key] == CardData.suits.back():
				returnSuit = CardData.suits[SUITBEG]
			else:
				returnSuit = CardData.suits[key + 1]
		'Left':
			if CardData.suits[key] == CardData.suits.front():
				returnSuit = CardData.suits[SUITEND]
			else:
				returnSuit = CardData.suits[key - 1]
	return(returnSuit)
