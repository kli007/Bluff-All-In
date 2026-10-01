extends Enemy

@export var charge_speed: float = 400.0
@export var charge_damage: float = 15.0

func _ready() -> void:
	damage = 5.0
	pass

func movement() -> void:
	pass # walk around and charge at enemy if they see
