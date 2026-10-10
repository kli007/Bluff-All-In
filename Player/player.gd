extends Entity

@onready var animNode: AnimationPlayer = $AnimationPlayer
@onready var deckNode: Node = $DeckManager
@onready var projNode: Node = $ProjectileManager
@onready var dashTime: Timer = $DashTimer
@onready var trickTime: Timer = $TrickTimer

@onready var pendNodes: Array = get_node('%HUD/PendCardsControl/PendCards').get_children()
@onready var playedNodes: Array = get_node('%HUD/UserUIControl/PlayedCards').get_children()

@export var DashSpeed: float = 800.0

signal needMultiplier

var lookingDir: String = ''
var burnActive: bool = false
var activeJumps: int = 3

var isActioning: State = State.NOTHING

const MAX_PLAYED_CARDS: int = 5
const MAX_PEND_CARDS: int = 7
const HEAL_BURN_MINIMUM: int = 2
const MAX_JUMP_AVAILABLE: int = 3
const ATTACK_ANIMATIONS: Dictionary = {'Attack_1': State.BASIC_ATTACK, 
'Up_Attack': State.LAUNCH_ATTACK, 'Down_Attack': State.SPIKE_ATTACK}

var currentTrick: Dictionary = {'rank': '3', 'suit': ''}

enum State {BASIC_ATTACK, LAUNCH_ATTACK, SPIKE_ATTACK, DASH_ATTACK, DASH, JUMP, SHOWDOWN, TRICK, NOTHING}

func _ready() -> void:
	super._ready()
	SaveManager.data_capture.connect(on_save_capture)
	SaveManager.data_dispense.connect(on_save_dispense)
	setPendCard()
	
func set_stats() -> void:
	speed = 200.0
	jump_velocity = -350.0
	max_health = 100
	max_hit_threshold = 5
	invincibility_time = .5

func _physics_process(delta: float) -> void:
	movement(delta)
		
	if isKnockback:
		velocity.x = knockbackVelocity.x
	elif isActioning == State.DASH:
		velocity.x = lastDirection.x * DashSpeed
	else:
		if direction:
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	if isActioning not in ATTACK_ANIMATIONS.values() and isActioning != State.SHOWDOWN:
		move_and_slide()
		animation_control()
		flip_sprite()
		if not is_on_floor() and isActioning != State.DASH:
			velocity += get_gravity() * delta
		else:
			activeJumps = MAX_JUMP_AVAILABLE
	
		
func animation_control() -> void:
	if isActioning == State.NOTHING:
		if velocity.y < 0:
			animNode.play('Jump')
		elif velocity.y > 0:
			animNode.play('Fall')
		elif velocity.x != 0:
			animNode.play('Move')
		else:
			animNode.play('Idle')
		

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
	needMultiplier.emit()
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
	
func slash_combo() -> void:
	pass # need for air rave 2 hit, and ground combo 3 hits
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name in ATTACK_ANIMATIONS:
		isActioning = State.NOTHING
	if anim_name == "Showdown":
		CombatManager.resetComboMult()
		isActioning = State.NOTHING
		
func _on_attack_timer_timeout() -> void:
	pass # Replace with function body.

func _on_dash_timer_timeout() -> void:
	isActioning = State.NOTHING
	velocity.x = 0
	
func _on_trick_timer_timeout() -> void:
	isActioning = State.NOTHING

func _on_hit_box_body_entered(body: Node2D) -> void:
	var damage: String = 'player_atk_dmg'
	match isActioning:
		State.LAUNCH_ATTACK:
			damage = 'player_launch_dmg'
		State.SPIKE_ATTACK:
			damage = 'player_spike_dmg'
		State.SHOWDOWN:
			damage = deckNode.lastPlayedHand
	if body is CharacterBody2D and body.name != 'Player':
		CombatManager.dealDamage(damage, body, global_position, self.name)

func movement(deltaTime: float) -> void:
	if isActioning != State.DASH:
		direction.x = Input.get_axis("Move_Left", "Move_Right")
	
	if direction:
		lastDirection = direction
		
	if Input.is_action_pressed("Look_Up") and (lookingDir == '' or lookingDir == 'UP'):
		lookingDir = 'UP'
	elif Input.is_action_just_released("Look_Up"):
		lookingDir = ''
		
	if Input.is_action_pressed("Look_Down") and (lookingDir == '' or lookingDir == 'DOWN'):
		lookingDir = 'DOWN'
	elif Input.is_action_just_released("Look_Down"):
		lookingDir = ''
		

	if Input.is_action_just_pressed("Move_Jump") and activeJumps > 0:
		velocity.y = jump_velocity
		activeJumps -= 1
		
	if Input.is_action_just_pressed("Delete"):
		deckNode.deleteDeck()
		
	if Input.is_action_just_pressed("Attack") and (isActioning == State.NOTHING or isActioning == State.DASH):
		if CardData.checkSpace(playedNodes) and CardData.checkSpace(pendNodes) < MAX_PEND_CARDS:
			if isActioning == State.DASH:
					animNode.play("Attack_1")
					dashTime.stop()
			if not is_on_floor():
				if lookingDir == 'DOWN':
					animNode.play("Down_Attack")
					isActioning = State.SPIKE_ATTACK
				else:
					animNode.play("Attack_1")
					isActioning = State.BASIC_ATTACK
			else:
				if lookingDir == 'UP':
					animNode.play("Up_Attack")
					isActioning = State.LAUNCH_ATTACK
				else:
					animNode.play("Attack_1")
					isActioning = State.BASIC_ATTACK
			setPlayedCard()
					
	
	if Input.is_action_just_pressed("Trick") and isActioning == State.NOTHING:
		if burnActive and (CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS):
			burnCards('jump')
			burnActive = false
		elif projNode.projectileCount and CardData.checkSpace(pendNodes) < MAX_PEND_CARDS:
			projNode.create_projectile(self, lastDirection, global_position)
			if not projNode.projectileCount:
				trickCards()
			trickTime.start()
			isActioning = State.TRICK
	if Input.is_action_pressed("Trick") and not burnActive:
		projNode.reloadProjectiles(deltaTime)
	if Input.is_action_just_released("Trick") and not burnActive:
		projNode.releaseReload()
		
	if Input.is_action_pressed('Burn'):
		burnActive = true
	elif Input.is_action_just_released('Burn'):
		burnActive = false
	
	if Input.is_action_just_pressed("Dash") and isActioning == State.NOTHING:
		if burnActive and CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
			burnCards('dash')
			burnActive = false
		dashTime.start()
		isActioning = State.DASH
	
	if Input.is_action_just_pressed("Showdown") and isActioning == State.NOTHING:
		if burnActive:
			if CardData.checkSpace(playedNodes) <= HEAL_BURN_MINIMUM:
				healthNode.changeHealth(30.0)
				burnCards('heal')
				burnActive = false
		elif CardData.checkSpace(playedNodes) < MAX_PLAYED_CARDS:
			animNode.play("Showdown")
			deckNode.checkHand(playedNodes)
			showdownPlayedCards()
			isActioning = State.SHOWDOWN
			
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
