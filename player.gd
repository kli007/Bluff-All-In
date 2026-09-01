extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = -350.0

@onready var animNode: Node = $AnimationPlayer
@onready var deckNode: Node = $DeckManager
@onready var pendCards: Node = get_node('/root/Main/HUD/PendCardsControl/PendCards')
@onready var playedCards: Node = get_node('/root/Main/HUD/UserUIControl/PlayedCards')

@onready var pendNodes: Array = pendCards.get_children()
@onready var playedNodes: Array = playedCards.get_children()

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
		setPlayedCard()
		attack = true
		animNode.play("Attack_1")
	if Input.is_action_just_pressed("Trick") and is_on_floor():
		setPendCard()
		
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
	while CardData.checkSpace(pendNodes):
		CardData.setCards(deckNode.moveCard(), pendNodes)
		
func setPlayedCard() -> void:
	if CardData.checkSpace(playedNodes) and not CardData.checkSpace(pendNodes):
		CardData.setCards(deckNode.playCard(pendNodes), playedNodes)
		moveUpPendCards()

func moveUpPendCards() -> void:
	CardData.moveUpCards(pendNodes)
	setPendCard()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack_1":
		attack = false
