extends Node

signal health_changed
signal health_empty

@export var health: float = 100.0
@export var isInvincible: bool = false
@onready var iTimer: Timer = $InvincTimer

var maxHealth: float = 100.0
var iFrames: float = 0.5

func takeHit(difference: float) -> void:
	if not isInvincible:
		changeHealth(difference)
		isInvincible = true
		iTimer.wait_time = iFrames
		iTimer.start()
		

func changeHealth(difference: float) -> void:
	health += difference
	health = clampf(health, 0, maxHealth)
	if health == 0:
		#respawn here
		health_empty.emit()
	health_changed.emit()
	
func setHealth(newHealth: float) -> void:
	var difference: float = newHealth - health
	changeHealth(difference)
	
func setMaxHealth(newMax: float) -> void:
	maxHealth = newMax
	health = maxHealth

func _on_invinc_timer_timeout() -> void:
	isInvincible = false
