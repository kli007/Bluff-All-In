extends Node

signal health_changed
signal health_empty

@export var health: float = 100.0
@export var isInvincible: bool = false
@export var currentHitPriority: int = 0

@onready var iTimer: Timer = $InvincTimer
@onready var hitTimer: Timer = $HitTimer

var maxHealth: float = 100.0
var iFrames: float = 0.5
var hitThreshold: int = 5

const maxPriority: int = 6

func isLocked() -> bool:
	return isInvincible and currentHitPriority >= hitThreshold

func checkIfHit(attackType: String) -> bool:
	return not isLocked() or CombatManager.ATTACKS[attackType]['hit_priority'] > currentHitPriority

func takeHit(difference: float, attack: String) -> bool:
	if not checkIfHit(attack):
		return false
	if not isLocked():
		hitTimer.start()
	changeHealth(difference)
	if attack == "Burn_Dash" or attack == "Burn_Grapple":
		reducePriority(10)
	else:
		currentHitPriority += CombatManager.ATTACKS[attack]['hit_priority']
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
	iTimer.stop()
	hitTimer.stop()
	
func startInvincible() -> void:
	isInvincible = true
	iTimer.start(iFrames)
	hitTimer.stop()

func _on_hit_timer_timeout() -> void:
	currentHitPriority = 0

func _on_invinc_timer_timeout() -> void:
	isInvincible = false
	currentHitPriority = 0

func reduceIframe() -> void:
	iTimer.stop()
	_on_invinc_timer_timeout()

func reducePriority(amount: int) -> void:
	currentHitPriority = clamp(currentHitPriority - amount, 0, maxPriority)
	if isInvincible and currentHitPriority < hitThreshold:
		iTimer.stop()
		isInvincible = false
