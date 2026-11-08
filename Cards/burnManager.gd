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
		var target: CharacterBody2D = getBody(bodies, player)
		if target == null:
			return
		target.getGrapple(player, grappleDistance, grapSpeed)
		CombatManager.dealDamage("Burn_Grapple", target, player.global_position, player)
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
	
func getBody(bodies: Array, player: CharacterBody2D) -> CharacterBody2D:
	var space: PhysicsDirectSpaceState2D = player.get_world_2d().direct_space_state
	var returnBody: CharacterBody2D = null
	var currentDist: float = INF
	for body in bodies:
		if body is not CharacterBody2D or body.name == "Player" or not body.canGrapple:
			continue
			
		var query := PhysicsRayQueryParameters2D.create(
				player.global_position, body.global_position, 1, [player.get_rid(), body.get_rid()])
		var hit: Dictionary = space.intersect_ray(query)
		if not hit.is_empty():
			continue
			
		var dist: float = body.global_position.distance_squared_to(player.global_position)
		var closer: bool = returnBody == null
		if not closer:
			if body.priorityGrapple != returnBody.priorityGrapple:
				closer = body.priorityGrapple
			else:
				closer = dist < currentDist
		if closer:
			returnBody = body
			currentDist = dist
			
	return returnBody
