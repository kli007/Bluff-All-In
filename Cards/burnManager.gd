extends Node

func mainManager(action: String, player: CharacterBody2D) -> void:
	match action:
		'dash':
			dashBurn(player)
		'grap':
			grapBurn()
		'heal':
			healBurn()

func dashBurn(playerNode: CharacterBody2D) -> void:
	var burnCard: Node2D = Global.playedNodes.front()
	CardData.hideCards(burnCard)
	CardData.moveUpCards(Global.playedNodes)
	playerNode.collision_layer = 2
	playerNode.collision_mask = 2
	
func grapBurn() -> void:
	var burnCard: Node2D
	var reverseNodes: Array = Global.playedNodes.duplicate()
	reverseNodes.reverse()
	for card in reverseNodes:
		if not card.checkData():
			burnCard = card
			break
	CardData.hideCards(burnCard)
	
func healBurn() -> void:
	var burnCards: Array
	if CardData.checkSpace(Global.playedNodes) > 1:
		burnCards = Global.playedNodes.slice(0,3)
	else:
		burnCards = Global.playedNodes.slice(1,4)
	for card in burnCards:
		CardData.hideCards(card)
	CardData.moveUpCards(Global.playedNodes)
	
	
	
