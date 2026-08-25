extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0

@onready var animNode: Node = $AnimationPlayer
@onready var cardNode: Node = $CardManager
@onready var pendCards: Node = get_node('/root/Main/HUD/PendCardsControl/PendCards')
@onready var playedCards: Node = get_node('/root/Main/HUD/UserUIControl/PlayedCards')

@onready var pendDict: Dictionary = pendCards.pendDict
@onready var playedDict: Dictionary = playedCards.playedDict
var pendNodes: Dictionary
var playedNodes: Dictionary

var attack: bool = false
var direction: float

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	direction = Input.get_axis("Move_Left", "Move_Right")
	
	if Input.is_action_just_pressed("Move_Jump") and is_on_floor():
		velocity.y = jump_velocity
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		setPendCard()
		attack = true
		animNode.play("Attack_1")
	if Input.is_action_just_pressed("Trick") and is_on_floor():
		setPlayedCard()
		
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
	var pendNodes: Dictionary = pendCards.nodeDict
	while CardData.checkSpace(pendDict):
		CardData.setCards(cardNode.moveCard(), 
		pendDict, pendNodes)
		
func setPlayedCard() -> void:
	var pendNodes: Dictionary = pendCards.nodeDict
	var playedNodes: Dictionary = playedCards.nodeDict
	if CardData.checkSpace(playedDict) and pendDict['Card1'] != null:
		CardData.setCards(cardNode.playCard(pendDict, pendNodes), playedDict, playedNodes)
		moveUpPendCards()

func moveUpPendCards() -> void:
	var pendNodes: Dictionary = pendCards.nodeDict
	CardData.moveUpCards(pendDict, pendNodes)
	setPendCard()
		

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack_1":
		attack = false
