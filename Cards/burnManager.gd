extends Node

func dashBurn(playedNodes: Array) -> void:
	var burnCard: Node = playedNodes.front()
	CardData.hideCards(burnCard)
	CardData.moveUpCards(playedNodes)
	
func jumpBurn(playedNodes: Array) -> void:
	var burnCard: Node
	var reverseNodes: Array = playedNodes.duplicate()
	reverseNodes.reverse()
	for card in reverseNodes:
		if not card.checkData():
			burnCard = card
			break
	CardData.hideCards(burnCard)
	
func healBurn(playedNodes: Array) -> void:
	var burnCards: Array
	if CardData.checkSpace(playedNodes) > 1:
		burnCards = playedNodes.slice(0,3)
	
	for card in burnCards:
		CardData.hideCards(card)
	
	
