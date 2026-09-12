extends Label
var playerHealth: Node = null

func _ready() -> void:
	playerHealth = get_node("/root/Main/Player/HealthManager")
	playerHealth.health_changed.connect(_on_player_health_changed)
	text = str("Player Health: ", 100)
	
	
func _on_player_health_changed() -> void:
	text = str("Player Health: ", playerHealth.health)
