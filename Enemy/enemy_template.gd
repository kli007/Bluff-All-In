extends CharacterBody2D
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 300

@onready var hLabel = $HealthControl/HealthLabel
@onready var health = $HealthManager

func _ready() -> void:
	health.health_changed.connect(_on_enemy_health_changed)
	health.setMaxHealth(MAX_HEALTH)
	hLabel.text = str("Health: ", MAX_HEALTH)
	
	
func _on_enemy_health_changed() -> void:
	hLabel.text = str("Health: ", health.health)
