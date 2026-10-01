class_name Enemy
extends CharacterBody2D
#need to change hurt and hit boxes and add damage to enemy
var cards: Resource = preload("res://Cards/dropCard.tscn")

@onready var hLabel = $HealthControl/HealthLabel
@onready var health = $HealthManager
@onready var knockTimer = $KnockbackTimer
@onready var spawnLocation: Vector2 = global_position

@export var damage: String = 'enemy_small_contact_dmg'
@export var speed: float = 150.0
@export var jump_velocity: float = -400.0
@export var max_health: float = 30000.0
@export var cardDrop: int = 5

var isKnockback: bool = false
var knockbackVelocity: Vector2


func _ready() -> void:
	health.health_changed.connect(_on_enemy_health_changed)
	health.health_empty.connect(death)
	health.setMaxHealth(max_health)
	hLabel.text = str("Health: ", max_health)
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if isKnockback:
		velocity.x = knockbackVelocity.x
	else:
		movement()
		
	move_and_slide()
	
func _on_enemy_health_changed() -> void:
	hLabel.text = str("Health: ", health.health)
	
func takeDamage(damage: float, knockback: float, playerPos: Vector2) -> void:
	health.changeHealth(-damage)
	takeKnockback(knockback, playerPos)
	
func takeKnockback(knockForce: float, playerPos: Vector2) -> void:
	var knockbackDir = (global_position - playerPos).normalized()
	knockbackVelocity = knockbackDir * knockForce
	knockTimer.start()
	isKnockback = true

func _on_knockback_timer_timeout() -> void:
	velocity.x = 0
	isKnockback = false
	
func movement() -> void:
	return

func respawn(new_location: Vector2) -> void:
	global_position = new_location
	health.setHealth(max_health)
	
func death() -> void:
	spawnCards()
	queue_free()
	
func spawnCards() -> void:
	var newCards: Array
	for card in cardDrop:
		var newSuit: String = CardData.suits.pick_random()
		var newRank: String = CardData.ranks.pick_random()
		newCards.append(newSuit + newRank)
	var items: Node = get_node("/root/Main/ItemGroup")
	var spawnedCards: Area2D = cards.instantiate()
	spawnedCards.setCardList(newCards)
	spawnedCards.global_position = global_position
	items.call_deferred('add_child', spawnedCards)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		CombatManager.dealDamage(damage, body, global_position, self.name)
