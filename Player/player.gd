extends CharacterBody2D

@export var speed: float = 200.0
@export var DashSpeed: float = 800.0
@export var jump_velocity: float = -350.0

@onready var animNode: Node = $AnimationPlayer
@onready var deckNode: Node = $DeckManager
@onready var healthNode: Node = $HealthManager
@onready var burnTime: Node = $BurnTimer
@onready var projNode: Node = $ProjectileManager

@onready var pendNodes: Array = get_node('%HUD/PendCardsControl/PendCards').get_children()
@onready var playedNodes: Array = get_node('%HUD/UserUIControl/PlayedCards').get_children()

@onready var spawnLocation: Vector2 = global_position

var attack: bool = false
var direction: float
var lastDirection: float
var isBurnDashing: bool = false

var isActioning: bool = false

const MAX_PLAYED_CARDS: int = 5
const MAX_PEND_CARDS: int = 7
const HEAL_BURN_MINIMUM: int = 2

var currentTrick: Dictionary = {'rank': '3', 'suit': ''}

func _ready() -> void:
	SaveManager.data_capture.connect(on_save_capture)
	SaveManager.data_dispense.connect(on_save_dispense)
	setPendCard()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	isActioning = false
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	controls(delta)
		
	if isBurnDashing:
		velocity.x = lastDirection * DashSpeed
	else:
		if direction and animNode.name != 'Jump':
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	if not attack:
		move_and_slide()
		animation_control()
		flip_sprite()
	
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
	if direction < 0:
		$Sprite2D.flip_h = true
	if direction > 0:
		$Sprite2D.flip_h = false
		
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
	if anim_name == "Attack_1":
		attack = false
		
func _on_burn_timer_timeout() -> void:
	isBurnDashing = false
	velocity.x = 0
	
func respawn(location: Vector2) -> void:
	position = location
		

func controls(deltaTime: float) -> void:
	if not isBurnDashing:
		direction = Input.get_axis("Move_Left", "Move_Right")
	
	if direction:
		lastDirection = direction

	if Input.is_action_just_pressed("Move_Jump") and is_on_floor():
		velocity.y = jump_velocity
		
	if Input.is_action_just_pressed("Delete"):
		deckNode.deleteDeck()
		
	if CardData.checkSpace(playedNodes) and CardData.checkSpace(pendNodes) < MAX_PEND_CARDS:
		if Input.is_action_just_pressed("Attack") and is_on_floor() and not isActioning:
			setPlayedCard()
			attack = true
			animNode.play("Attack_1")
			isActioning = true
			
			
		if Input.is_action_just_pressed("Trick") and projNode.projectileCount and not isActioning:
			projNode.create_projectile(self, lastDirection, global_position)
			if not projNode.projectileCount:
				trickCards()
			isActioning = true
		
		if Input.is_action_pressed("Trick"):
			projNode.reloadProjectiles(deltaTime)
			
		if Input.is_action_just_released("Trick"):
			projNode.releaseReload()
		
	if CardData.checkSpace(playedNodes) <= HEAL_BURN_MINIMUM:
		if Input.is_action_just_pressed("Burn") and Input.is_action_pressed("Temp") and not isActioning:
			healthNode.changeHealth(30.0)
			burnCards('heal')
			isActioning = true
			
	if CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
		if Input.is_action_just_pressed("Burn") and not is_on_floor() and not isActioning:
			velocity.y = jump_velocity
			burnCards('jump')
			isActioning = true
		elif Input.is_action_just_pressed("Burn") and not isActioning:
			isBurnDashing = true
			burnCards('dash')
			burnTime.start()
			isActioning = true
	
	if CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
		if Input.is_action_just_pressed("Showdown") and not isActioning:
			deckNode.checkHand(playedNodes)
			showdownPlayedCards()
			isActioning = true
			
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
