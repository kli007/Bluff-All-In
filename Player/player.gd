extends Entity

@onready var deckNode: Node = $DeckManager
@onready var projNode: Node = $ProjectileManager
@onready var comboTime: Timer = $ComboTimer
@onready var dashTime: Timer = $DashTimer
@onready var trickTime: Timer = $TrickTimer
@onready var grapRay: ShapeCast2D = $GrappleRay
@export var DashSpeed: float = 800.0

signal needMultiplier

var burnActive: bool = false
var activeJumps: int = 3
var currentAttack: String

var isActioning: State = State.IDLE

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
	var friction: float
	movement(delta)
	
	if is_on_floor(): #bug here!!!!!!!
		friction = groundRay.get_collider().friction
	else:
		friction = Global.air_friction
		
	if isStatus == STATUS.KNOCKBACK:
		velocity.x = statusVelocity.x
	elif isStatus == STATUS.RECOIL:
		velocity = statusVelocity
	elif isActioning == State.DASH:
		velocity.x = (lastDirection.x/abs(lastDirection.x)) * DashSpeed
	else:
		if direction:
			velocity.x = move_toward(velocity.x, direction.x * speed, acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, friction)

	if (isActioning != State.SHOWDOWN
	 and isActioning != State.GRAPPLE):
		move_and_slide()
		animation_control()
		flip_sprite()
		if (not is_on_floor() and isActioning != State.DASH
		 and isActioning != State.ATTACK):
			velocity += get_gravity() * delta
		else:
			activeJumps = MAX_JUMP_AVAILABLE
	
		
func animation_control() -> void:
	match isActioning:
		State.IDLE:
			if velocity.y < 0:
				animNode.play('JUMP')
			elif velocity.y > 0:
				animNode.play('FALL')
			elif velocity.x != 0:
				animNode.play('MOVE')
			else:
				animNode.play('IDLE')
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
	if currentAttack == "G_Attack_2":
		currentAttack = "G_Attack_3"
	elif currentAttack == "G_Attack_1":
		currentAttack = "G_Attack_2"
	else:
		currentAttack = "G_Attack_1"
		
	comboTime.start()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "SHOWDOWN":
		CombatManager.resetComboMult()
	if anim_name == "DASH":
		collision_layer = 1
		collision_mask = 1
		velocity.x = 0
	if (anim_name == "GRAPPLE" or currentAttack == "A_Attack_1" 
	or currentAttack == "A_Attack_2"):
		startHovering()
	if anim_name == "JUMP":
		isActioning = State.JUMP
		return
	if anim_name == "FALL":
		isActioning = State.FALL
		return
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
			damage = currentAttack
		State.SHOWDOWN:
			damage = deckNode.lastPlayedHand
		State.DASH:
			damage = "Burn_Dash"
	CombatManager.dealDamage(damage, body, global_position, self.name)

func movement(deltaTime: float) -> void:
	if isActioning != State.DASH:
		direction.x = Input.get_axis("Move_Left", "Move_Right")
		direction.y = Input.get_axis("Look_Up", "Look_Down")
		
	if direction:
		lastDirection = direction
		
	if Input.is_action_just_released("Look_Up") or Input.is_action_just_released("Look_Down"):
		lastDirection.y = 0.0
		
		
	if Input.is_action_just_pressed("Move_Jump") and activeJumps > 0:
		velocity.y = jump_velocity
		activeJumps -= 1
		
	if Input.is_action_just_pressed("Delete"):
		deckNode.deleteDeck()
		
	if Input.is_action_just_pressed("Attack") and (isActioning == State.IDLE or isActioning == State.DASH):
		if CardData.checkSpace(Global.playedNodes) and CardData.checkSpace(Global.pendNodes) < MAX_PEND_CARDS:
			comboTime.stop()
			if isActioning == State.DASH:
					currentAttack = "G_Attack_1"
					dashTime.stop()
			if not is_on_floor():
				if lastDirection.y > 0.0:
					currentAttack = "Down_Attack"
				else:
					slash_combo()
			else:
				if lastDirection.y < 0.0:
					currentAttack = "Up_Attack"
				else:
					slash_combo()
			#setPlayedCard()
			animNode.play(currentAttack)
			isActioning = State.ATTACK
					
	
	if Input.is_action_just_pressed("Trick") and isActioning == State.IDLE:
		if burnActive and (CardData.checkSpace(Global.playedNodes) < MAX_PLAYED_CARDS):
			BurnManager.mainManager("grap", self)
			burnActive = false
			animNode.play("GRAPPLE")
			isActioning = State.GRAPPLE
		elif projNode.projectileCount and CardData.checkSpace(Global.pendNodes) < MAX_PEND_CARDS:
			projNode.create_projectile(self, lastDirection, global_position)
			if not projNode.projectileCount:
				TrickManager.mainManager()
				setPlayedCard()
			animNode.play("SHOOT")
			isActioning = State.TRICK
	if Input.is_action_pressed("Trick") and not burnActive:
		projNode.reloadProjectiles(deltaTime)
	if Input.is_action_just_released("Trick") and not burnActive:
		projNode.releaseReload()
		
	if Input.is_action_pressed('Burn'):
		burnActive = true
	elif Input.is_action_just_released('Burn'):
		burnActive = false
	
	if Input.is_action_just_pressed("Dash") and isActioning == State.IDLE:
		if burnActive and CardData.checkSpace(Global.playedNodes) < MAX_PLAYED_CARDS:
			BurnManager.mainManager('dash', self)
			burnActive = false
		animNode.play("DASH")
		dashTime.start()
		isActioning = State.DASH
	
	if Input.is_action_just_pressed("Showdown") and isActioning == State.IDLE:
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
		
	BurnManager.rotateGrapple(grapRay, lastDirection)
	
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
