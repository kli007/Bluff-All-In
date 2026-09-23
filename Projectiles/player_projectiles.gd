extends Label
var playerProjectiles: Node = null

func _ready() -> void:
	playerProjectiles = get_node("/root/Main/Player/ProjectileManager")
	playerProjectiles.proj_changed.connect(_on_player_projectiles_changed)
	playerProjectiles.reload_status.connect(_on_player_reload_changed)
	text = str("Projectiles: ", 0)
	
func _on_player_projectiles_changed() -> void:
	text = str("Projectiles: ", playerProjectiles.projectileCount)
	
func _on_player_reload_changed() -> void:
	text = "Reload Complete"
