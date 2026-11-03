extends Node
@export var grappleDistance: float = 30.0
@export var grapSpeed: float = 700.0

func mainManager(action: String, player: CharacterBody2D) -> void:
	match action:
		'dash':
			dashBurn(player)
		'grap':
			grapBurn(player, player.grapBox)
		'heal':
			healBurn()

func dashBurn(playerNode: CharacterBody2D) -> void:
	var burnCard: Node2D = Global.playedNodes.front()
	CardData.hideCards(burnCard)
	CardData.moveUpCards(Global.playedNodes)
	playerNode.collision_layer = 2
	playerNode.collision_mask = 2
	
func grapBurn(player: CharacterBody2D, grapple: Area2D) -> void:
	var burnCard: Node2D
	var reverseNodes: Array = Global.playedNodes.duplicate()
	reverseNodes.reverse()
	for card in reverseNodes:
		if not card.checkData():
			burnCard = card
			break
	var bodies: Array = grapple.get_overlapping_bodies()
	if bodies.is_empty():
		return
	else:
		var target: CharacterBody2D
		for body in bodies: # this needs to be changed
			if body is CharacterBody2D:
				if body.canGrapple:
					target = body
		if not target:
			return
		target.getGrapple(player, grappleDistance, grapSpeed)
		CombatManager.dealDamage("Burn_Grapple", target, player.global_position, player.name)
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
