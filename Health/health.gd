extends Node

signal health_changed
signal health_empty
signal invincibility_started
signal invincibility_ended

@export var health: float = 100.0
@export var isInvincible: bool = false
@export var currentHitPriority: int = 0

@onready var iTimer: Timer = $InvincTimer
@onready var hitTimer: Timer = $HitTimer

var maxHealth: float = 100.0
var iFrames: float = .5
var hitThreshold: int = 5

const maxPriority: int = 6

func checkIfHit(attackType: String) -> bool:
	return CombatManager.getAttackPriority(attackType) > currentHitPriority

func takeHit(difference: float, attack: String) -> bool:
	if isInvincible:
		if not checkIfHit(attack):
			return false
	else:
		hitTimer.start()
	changeHealth(difference)
	currentHitPriority += CombatManager.getAttackPriority(attack)
	currentHitPriority = clampi(currentHitPriority, 0, maxPriority)
	if currentHitPriority >= hitThreshold:
		startInvincible()
	return true
		
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
	
func setAllValues(newMax: float, newThreshold: int, newIFrame: float) -> void:
	maxHealth = newMax
	hitThreshold = newThreshold
	iFrames = newIFrame
	health = maxHealth
	
func resetAllValues() -> void:
	setHealth(maxHealth)
	currentHitPriority = 0
	isInvincible = false
	invincibility_ended.emit()
	iTimer.stop()
	hitTimer.stop()
	
func startInvincible() -> void:
	isInvincible = true
	iTimer.start(iFrames)
	hitTimer.stop()
	invincibility_started.emit()

func _on_hit_timer_timeout() -> void:
	currentHitPriority = 0

func _on_invinc_timer_timeout() -> void:
	isInvincible = false
	currentHitPriority = 0
	invincibility_ended.emit()

func reduceIframe() -> void:
	pass

func reducePriority() -> void:
	pass
