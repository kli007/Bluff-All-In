extends Node
var projectile = preload("res://Player/projectile.tscn")

signal proj_changed
signal reload_status

@export var projectileCount: int = 0

var justReloaded: bool = false
var currentProjTime: float = 0.0
const MAX_PROJ_COUNT: int = 4  # can be changed later
const RELOAD_TIME: float = 1.0

func create_projectile(playerNode: Node, playerDirection: Vector2, playerGP: Vector2) -> void:
	var Proj = get_parent().get_parent().get_node("ProjectileGroup")
	var new_projectile = projectile.instantiate()
	new_projectile.global_position = playerGP
	new_projectile.lock_on_to_player(playerDirection, playerNode, Proj)
	Proj.call_deferred("add_child", new_projectile)
	projectileCount -= 1
	proj_changed.emit()
	
func reloadProjectiles(delta: float) -> void:
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
		proj_changed.emit()
		
func setProjectiles(newProjs: int) -> void:
	projectileCount = newProjs
	proj_changed.emit()
