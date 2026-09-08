extends Node

signal health_changed

@export var health: float = 100.0
var maxHealth: float = 100.0

func changeHealth(difference: float) -> void:
	health += difference
	health = clampf(health, 0, maxHealth)
	if health == 0:
		#respawn here
		health = maxHealth
	health_changed.emit()
	
	
func getHealth() -> float:
	return health
