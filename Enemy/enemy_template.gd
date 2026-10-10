class_name Enemy
extends Entity
#need to change hurt and hit boxes and add damage to enemy
var cards: Resource = preload("res://Cards/dropCard.tscn")

@onready var hLabel: Label = $HealthControl/HealthLabel

@export var contact_damage: String = 'enemy_small_contact_dmg'
@export var cardDrop: int = 5

func set_stats() -> void:
	speed = 150.0
	jump_velocity = -400.0
	max_health = 30000.0
	max_hit_threshold = 5
	invincibility_time = 1.5

func unique_ready() -> void:
	healthNode.health_changed.connect(_on_enemy_health_changed)
	hLabel.text = str("Health: ", max_health)
	
	
func _on_enemy_health_changed() -> void:
	hLabel.text = str("Health: ", healthNode.health)

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
		CombatManager.dealDamage(contact_damage, body, global_position, self.name)

func unique_hit(damageType: String) -> void:
	CombatManager.enemy_hit.emit(CombatManager.HIT_NAMES[damageType])
