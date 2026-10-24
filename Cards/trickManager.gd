extends Node

const RANKMAX: int = 12
const RANKMIN: int = 0
const SUITEND: int = 3
const SUITBEG: int = 0

var currentTrick: Dictionary = {'rank': '3', 'suit': ''}

func mainManager() -> void:
	var cardNode: Node2D = Global.pendNodes.front()
	var cardRank: String = cardNode.rank
	var cardSuit: String = cardNode.suit
	
	var newRank: String = cardRank
	var newSuit: String = cardSuit
	
	if currentTrick["rank"]:
		newRank = changeRank(cardRank)
	if currentTrick["suit"]:
		newSuit = changeSuit(cardSuit)
		
	cardNode.setData(newSuit, newRank)
	CardData.changeCardSprite(cardNode)
	
func changeRank(current: String) -> String:
	var key: int = CardData.ranks.find(current)
	var returnRank: String = current
	match(currentTrick["rank"]):
		'Increase':
			if key < RANKMAX:
				returnRank = CardData.ranks[key + 1]
		'Decrease':
			if key > RANKMIN: 
				returnRank = CardData.ranks[key - 1]
		_:#just for matching
			if currentTrick["rank"] != '':
				returnRank = currentTrick["rank"]
	return(returnRank)
	
func changeSuit(current: String) -> String:
	var key: int = CardData.suits.find(current)
	var returnSuit: String = current
	match(currentTrick["suit"]):
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
		_: #just for matching
			if currentTrick["suit"] != '':
				returnSuit = currentTrick["suit"]
	return(returnSuit)
