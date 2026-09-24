extends CharacterBody2D

@export var speed: float = 200.0
@export var DashSpeed: float = 800.0
@export var jump_velocity: float = -350.0

@onready var animNode: Node = $AnimationPlayer
@onready var deckNode: Node = $DeckManager
@onready var healthNode: Node = $HealthManager
@onready var dashTime: Node = $DashTimer
@onready var trickTime: Node = $TrickTimer
@onready var projNode: Node = $ProjectileManager
@onready var visNode: Node = $VisualManager

@onready var pendNodes: Array = get_node('%HUD/PendCardsControl/PendCards').get_children()
@onready var playedNodes: Array = get_node('%HUD/UserUIControl/PlayedCards').get_children()

@onready var spawnLocation: Vector2 = global_position

signal comboChanged

var direction: Vector2
var lastDirection: Vector2 = Vector2.RIGHT
var burnActive: bool = false

var isActioning: String = ''

const MAX_PLAYED_CARDS: int = 5
const MAX_PEND_CARDS: int = 7
const HEAL_BURN_MINIMUM: int = 2

var currentTrick: Dictionary = {'rank': '3', 'suit': ''}

func _ready() -> void:
	SaveManager.data_capture.connect(on_save_capture)
	SaveManager.data_dispense.connect(on_save_dispense)
	setPendCard()

func _physics_process(delta: float) -> void:
	controls(delta)
		
	if isActioning == 'dash':
		velocity.x = lastDirection.x * DashSpeed
	else:
		if direction and animNode.name != 'Jump':
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	if isActioning != 'attack' and isActioning != 'showdown':
		move_and_slide()
		animation_control()
		flip_sprite()
		if not is_on_floor():
			velocity += get_gravity() * delta
		
func animation_control() -> void:
	if velocity.y < 0:
		animNode.play('Jump')
	elif velocity.y > 0:
		animNode.play('Fall')
	elif velocity.x != 0:
		animNode.play('Move')
	else:
		animNode.play('Idle')
	
func flip_sprite() -> void:
	if direction.x < 0:
		visNode.scale.x = -1
	if direction.x > 0:
		visNode.scale.x = 1
		
func setPendCard() -> void:
	while CardData.checkSpace(pendNodes) and not deckNode.checkDeck():
		CardData.setCards(deckNode.moveCard(), pendNodes)
		
func setPlayedCard() -> void:
	CardData.setCards(deckNode.playCard(pendNodes), playedNodes)
	moveUpPendCards()

func moveUpPendCards() -> void:
	CardData.moveUpCards(pendNodes)
	setPendCard()
	
func showdownPlayedCards() -> void:
	CardData.removeCards(playedNodes)
		
func burnCards(action: String) -> void:
	match action:
		'dash':
			BurnManager.dashBurn(playedNodes)
		'jump':
			BurnManager.jumpBurn(playedNodes)
		'heal':
			BurnManager.healBurn(playedNodes)
	
func trickCards() -> void:
	TrickManager.mainManager(pendNodes.front(), currentTrick['rank'], currentTrick['suit'])
	setPlayedCard()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack_1" or anim_name == "Showdown":
		isActioning = ''

func respawn(location: Vector2) -> void:
	position = location
		
func _on_dash_timer_timeout() -> void:
	isActioning = ''
	velocity.x = 0
	
func _on_trick_timer_timeout() -> void:
	isActioning = ''

func _on_hurtbox_body_entered(body: Node2D) -> void:
	var damage: String
	var comboSignal: String
	match isActioning:
		"attack":
			damage = 'player_atk_dmg'
			comboSignal = 'Attack'
		'showdown':
			damage = deckNode.lastPlayedHand
			comboSignal = deckNode.emitHand
	if body is CharacterBody2D and body.name != 'Player':
		comboChanged.emit(comboSignal)
		CombatManager.dealDamage(damage, 'medium_kb', body, global_position)

func controls(deltaTime: float) -> void:
	if isActioning != 'dash':
		direction.x = Input.get_axis("Move_Left", "Move_Right")
	
	if direction:
		lastDirection = direction

	if Input.is_action_just_pressed("Move_Jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("Delete"):
		deckNode.deleteDeck()
		
	if Input.is_action_just_pressed("Attack") and not isActioning:
		if CardData.checkSpace(playedNodes) and CardData.checkSpace(pendNodes) < MAX_PEND_CARDS:
			setPlayedCard()
			animNode.play("Attack_1")
			isActioning = 'attack'
	
	if Input.is_action_just_pressed("Trick") and not isActioning:
		if burnActive and (CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS):
			burnCards('jump')
			burnActive = false
		elif projNode.projectileCount and CardData.checkSpace(pendNodes) < MAX_PEND_CARDS:
			projNode.create_projectile(self, lastDirection, global_position)
			if not projNode.projectileCount:
				trickCards()
			trickTime.start()
			isActioning = 'trick'
	if Input.is_action_pressed("Trick") and not burnActive:
		projNode.reloadProjectiles(deltaTime)
	if Input.is_action_just_released("Trick") and not burnActive:
		projNode.releaseReload()
		
	if Input.is_action_pressed('Burn'):
		burnActive = true
	elif Input.is_action_just_released('Burn'):
		burnActive = false
	
	if Input.is_action_just_pressed("Dash") and not isActioning:
		if burnActive and CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
			burnCards('dash')
			burnActive = false
		dashTime.start()
		isActioning = 'dash'
			
	'''velocity.y = jump_velocity
	burnCards('jump')
	isActioning = true rework double jump later'''
	
	if Input.is_action_just_pressed("Showdown") and not isActioning:
		if burnActive:
			if CardData.checkSpace(playedNodes) <= HEAL_BURN_MINIMUM:
				healthNode.changeHealth(30.0)
				burnCards('heal')
				burnActive = false
		elif CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
			animNode.play("Showdown")
			deckNode.checkHand(playedNodes)
			showdownPlayedCards()
			isActioning = 'showdown'
			
	if Input.is_action_pressed("DeleteHealthDebug"):
		healthNode.changeHealth(-1.0)
		
	if Input.is_action_just_pressed("Save Game"):
		SaveManager.saveGame()
	
	if Input.is_action_just_pressed("Load Game" ):
		SaveManager.loadGame()
	
	
func on_save_capture(data: SaveData) -> void:
	data.player_health = healthNode.health
	data.player_location = global_position
	data.player_projectiles = projNode.projectileCount
	data.current_deck = deckNode.activeArray
	data.pend_cards = CardData.exportCardList(pendNodes)
	data.played_cards = CardData.exportCardList(playedNodes)
	
func on_save_dispense(data: SaveData) -> void:
	healthNode.setHealth(data.player_health)
	global_position = data.player_location
	projNode.setProjectiles(data.player_projectiles)
	deckNode.activeArray = data.current_deck
	load_cards(data.pend_cards, pendNodes)
	load_cards(data.played_cards, playedNodes)
		
func load_cards(cardArray: Array, cardNodes: Array) -> void:
	CardData.removeCards(cardNodes)
	for card in cardArray:
		if card['rank'] != '' and card['suit'] != '':
			CardData.setCards(card, cardNodes)
