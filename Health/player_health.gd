extends TextureProgressBar
var playerHealth: Node = null

func _ready() -> void:
	playerHealth = get_node("/root/Main/Player/HealthManager")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = playerHealth.health
