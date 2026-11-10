extends Entity

@onready var deckNode: Node = $DeckManager
@onready var projNode: Node = $ProjectileManager
@onready var comboTime: Timer = $ComboTimer
@onready var dashTime: Timer = $DashTimer
@onready var trickTime: Timer = $TrickTimer
@onready var grapRay: ShapeCast2D = $GrappleRay
@onready var grapBox: Area2D = $VisualManager/Grapplebox
@export var DashSpeed: float = 200.0
@export var currentAttack: String

signal needMultiplier
signal dragFinished

var burnActive: bool = false
var activeJumps: int = 3
var airAction: bool
var isActioning: State = State.IDLE
var launchVelocity: float = -500.0
var spikeVelocity: float = 500.0

var helperCond: bool
var gravityCond: bool

const MAX_PLAYED_CARDS: int = 5
const MAX_PEND_CARDS: int = 7
const HEAL_BURN_MINIMUM: int = 2
const MAX_JUMP_AVAILABLE: int = 3

enum State {ATTACK, DASH, GRAPPLE, JUMP, FALL, SHOWDOWN, TRICK, IDLE, HURT}

func _ready() -> void:
	super._ready()
	animNode = $AnimationPlayer
	Global.data_capture.connect(on_save_capture)
	Global.data_dispense.connect(on_save_dispense)
	CombatManager.playerRecoil.connect(startRecoil)
	setPendCard()
	
func set_stats() -> void:
	speed = 200.0
	acceleration = 20
	jump_velocity = -450.0
	max_health = 100
	max_hit_threshold = 5
	invincibility_time = .5

func _physics_process(delta: float) -> void:
	helperCond = true
	gravityCond = true
	physics(delta)
	checkStatus(delta)
	checkAction()
	if helperCond:
		moveHelper()
		if is_on_floor():
			airAction = true
			if animNode.current_animation in ["Down_Attack", "Down_Attack_2"]:
				animNode.stop()
				isActioning = State.IDLE
				dragFinished.emit()
			if gravityCond:
				activeJumps = MAX_JUMP_AVAILABLE
			
func checkAction() -> void:
	match isActioning:
		State.DASH:
			velocity.x += (lastDirection.x/abs(lastDirection.x)) * DashSpeed 
			gravityCond = false
		State.JUMP:
			if velocity.y < 0:
				animNode.play("JUMPING")
			else:
				isActioning = State.IDLE
		State.FALL:
			if velocity.y > 0:
				animNode.play("FALLING")
			else:
				isActioning = State.IDLE
		State.SHOWDOWN:
			helperCond = false
		State.GRAPPLE:
			helperCond = isStatus != STATUS.GRAPPLE
		State.ATTACK:
			gravityCond = false
		State.IDLE:
			if velocity.y < 0:
				animNode.play('JUMP')
			elif velocity.y > 0:
				animNode.play('FALL')
			elif velocity.x != 0:
				animNode.play('MOVE')
			else:
				animNode.play('IDLE')

func setPendCard() -> void:
	while CardData.checkSpace(Global.pendNodes) and not deckNode.checkDeck():
		CardData.setCards(deckNode.moveCard(), Global.pendNodes)
		
func setPlayedCard() -> void:
	CardData.setCards(deckNode.playCard(Global.pendNodes), Global.playedNodes)
	moveUpPendCards()

func moveUpPendCards() -> void:
	CardData.moveUpCards(Global.pendNodes)
	setPendCard()
	
func showdownPlayedCards() -> void:
	needMultiplier.emit()
	CardData.removeCards(Global.playedNodes)
	
func slash_combo() -> void:
	if not is_on_floor():
		airAction = false
		if currentAttack == "A_Attack_1":
			animNode.play("A_Attack_2")
		else:
			animNode.play("A_Attack_1")
	else:
		if currentAttack == "G_Attack_2":
			animNode.play("G_Attack_3")
		elif currentAttack == "G_Attack_1":
			animNode.play("G_Attack_2")
		else:
			animNode.play("G_Attack_1")
	comboTime.start()
	
func drag(attack: String) -> void:
	match attack:
		"Launcher":
			velocity.y = launchVelocity
		"Spike":
			velocity.y = spikeVelocity
			
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "SHOWDOWN":
		CombatManager.resetComboMult()
	if anim_name == "DASH":
		collision_layer = 1
		collision_mask = 1
		velocity.x = 0
	if anim_name == "JUMP":
		isActioning = State.JUMP
		return
	if anim_name == "FALL":
		isActioning = State.FALL
		return
	if anim_name == "Up_Attack":
		dragFinished.emit()
	if anim_name == "Down_Attack":
		animNode.play("Down_Attack_2")
	isActioning = State.IDLE
		
func _on_combo_timer_timeout() -> void:
	currentAttack = ""
	
func _on_trick_timer_timeout() -> void:
	isActioning = State.IDLE

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == 'Player' or body is not CharacterBody2D:
		return
	var damage: String = 'player_atk_dmg'
	match isActioning:
		State.ATTACK:
			if animNode.current_animation == "Down_Attack_2":
				damage = "Down_Attack"
			else:
				damage = animNode.current_animation
		State.SHOWDOWN:
			damage = deckNode.lastPlayedHand
		State.DASH:
			damage = "Burn_Dash"
	CombatManager.dealDamage(damage, body, global_position, self)

func movement(deltaTime: float) -> void:
	if isActioning != State.DASH:
		direction.x = Input.get_axis("Move_Left", "Move_Right")
		lastDirection.y = Input.get_axis("Look_Up", "Look_Down")
		
	if direction.x:
		lastDirection.x = direction.x
		velocity.x = move_toward(velocity.x, direction.x * speed, acceleration)
		
	if (Input.is_action_just_pressed("Move_Jump") and activeJumps > 0 and
	isActioning in [State.IDLE, State.DASH, State.JUMP, State.FALL]):
		velocity.y = jump_velocity
		activeJumps -= 1
		airAction = true
		if isActioning == State.DASH:
			pass
		
	if Input.is_action_just_pressed("Delete"):
		deckNode.deleteDeck()
		
	if (Input.is_action_just_pressed("Attack") and airAction and 
	isActioning in [State.IDLE, State.DASH, State.JUMP, State.FALL]):
		if CardData.checkSpace(Global.playedNodes) and CardData.checkSpace(Global.pendNodes) < MAX_PEND_CARDS:
			if isActioning == State.DASH:
					animNode.play("G_Attack_1")
					dashTime.stop()
			if not is_on_floor():
				if lastDirection.y > 0.0:
					animNode.play("Down_Attack")
				else:
					slash_combo()
			else:
				if lastDirection.y < 0.0:
					animNode.play("Up_Attack")
				else:
					slash_combo()
			isActioning = State.ATTACK
					
	
	if Input.is_action_just_pressed("Trick") and isActioning in [State.IDLE, State.JUMP, State.FALL]:
		if burnActive and (CardData.checkSpace(Global.playedNodes) < MAX_PLAYED_CARDS):
			BurnManager.mainManager("grap", self)
			burnActive = false
			animNode.play("GRAPPLE")
			isActioning = State.GRAPPLE
			if isStatus != STATUS.GRAPPLE:
				startHovering()
		elif CardData.checkSpace(Global.pendNodes) < MAX_PEND_CARDS:
			projNode.create_projectile(self, lastDirection, global_position)
			animNode.play("SHOOT")
			isActioning = State.TRICK

	if Input.is_action_pressed('Burn'):
		burnActive = true
	elif Input.is_action_just_released('Burn'):
		burnActive = false
	
	if Input.is_action_just_pressed("Dash") and isActioning in [State.IDLE, State.JUMP, State.FALL]:
		if burnActive and CardData.checkSpace(Global.playedNodes) < MAX_PLAYED_CARDS:
			BurnManager.mainManager('dash', self)
			burnActive = false
		animNode.play("DASH")
		dashTime.start()
		isActioning = State.DASH
	
	if Input.is_action_just_pressed("Showdown") and isActioning in [State.IDLE, State.JUMP, State.FALL]:
		if burnActive:
			if CardData.checkSpace(Global.playedNodes) <= HEAL_BURN_MINIMUM:
				healthNode.changeHealth(30.0)
				BurnManager.mainManager('heal', self)
				burnActive = false
		elif CardData.checkSpace(Global.playedNodes) < MAX_PLAYED_CARDS:
			animNode.play("SHOWDOWN")
			deckNode.checkHand()
			showdownPlayedCards()
			isActioning = State.SHOWDOWN
			
	if Input.is_action_pressed("DeleteHealthDebug"):
		healthNode.changeHealth(-1.0)
		
	if Input.is_action_just_pressed("Save Game"):
		Global.saveGame()
	
	if Input.is_action_just_pressed("Load Game" ):
		Global.loadGame()
	
func hoverMovement(delta: float) -> void:
	movement(delta)
	
func on_save_capture(data: SaveData) -> void:
	data.player_health = healthNode.health
	data.player_location = global_position
	data.player_projectiles = projNode.projectileCount
	data.current_deck = deckNode.activeArray
	data.pend_cards = CardData.exportCardList(Global.pendNodes)
	data.played_cards = CardData.exportCardList(Global.playedNodes)
	
func on_save_dispense(data: SaveData) -> void:
	healthNode.setHealth(data.player_health)
	global_position = data.player_location
	projNode.setProjectiles(data.player_projectiles)
	deckNode.activeArray = data.current_deck
	load_cards(data.pend_cards, Global.pendNodes)
	load_cards(data.played_cards, Global.playedNodes)
		
func load_cards(cardArray: Array, cardNodes: Array) -> void:
	CardData.removeCards(cardNodes)
	for card in cardArray:
		if card['rank'] != '' and card['suit'] != '':
			CardData.setCards(card, cardNodes)
			
func unique_hit(damageType: String, damagePos: Vector2) -> void:
	super.unique_hit(damageType, damagePos)
	isActioning = State.HURT
