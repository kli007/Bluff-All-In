extends CharacterBody2D

@export var speed: float = 200.0
@export var DashSpeed: float = 800.0
@export var jump_velocity: float = -350.0

@onready var animNode: Node = $AnimationPlayer
@onready var deckNode: Node = $DeckManager
@onready var health: Node = $HealthManager
@onready var burnTime: Node = $BurnTimer
@onready var projectiles: Node = $ProjectileManager

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

var currentTrick: Dictionary = {'rank': 'Increase', 'suit': ''}

func _ready() -> void:
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
		CardData.showdownCards(playedNodes)
		
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
			
			
		if Input.is_action_just_pressed("Trick") and projectiles.projectileCount and not isActioning:
			projectiles.create_projectile(self, lastDirection, global_position)
			if not projectiles.projectileCount:
				trickCards()
			isActioning = true
		
		if Input.is_action_pressed("Trick"):
			projectiles.reloadProjectiles(deltaTime)
			
		if Input.is_action_just_released("Trick"):
			projectiles.releaseReload()
		
	if CardData.checkSpace(playedNodes) <= HEAL_BURN_MINIMUM:
		if Input.is_action_just_pressed("Burn") and Input.is_action_pressed("Temp") and not isActioning:
			health.changeHealth(30.0)
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
		health.changeHealth(-1.0)
	
	

	
