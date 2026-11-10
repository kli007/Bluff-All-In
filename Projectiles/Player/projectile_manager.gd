extends Node
var projectile: Resource = preload("res://Projectiles/Player/projectile.tscn")

signal proj_changed()
signal reload_status

@export var projectileLanded: int = MAX_PROJ_LAND

#var justReloaded: bool = false
var currentProjTime: float = 0.0
const MAX_PROJ_LAND: int = 4  # can be changed later
#const RELOAD_TIME: float = 1.0

func create_projectile(playerNode: Node, playerDirection: Vector2, playerGP: Vector2) -> void:
	var Proj: Node = Global.mainNode.get_node("ProjectileGroup")
	var new_projectile: Area2D = projectile.instantiate()
	
	new_projectile.global_position = playerGP
	new_projectile.lock_on_to_player(playerDirection, playerNode, Proj)
	Proj.call_deferred("add_child", new_projectile)
	#projectileLanded -= 1
	proj_changed.emit(projectileLanded)
	
'func reloadProjectiles(delta: float) -> void:
	if not justReloaded:
		currentProjTime += delta
		if currentProjTime >= RELOAD_TIME:
			justReloaded = true
			reload_status.emit()

func releaseReload() -> void:
	if justReloaded:
		projectileCount = MAX_PROJ_COUNT
		currentProjTime = 0.0
		justReloaded = false
		proj_changed.emit()'
		
func setProjectiles(newProjs: int = MAX_PROJ_LAND) -> void:
	projectileLanded = newProjs
	proj_changed.emit()
	
