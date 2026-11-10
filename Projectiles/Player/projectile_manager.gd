extends Node
var projectile: Resource = preload("res://Projectiles/Player/projectile.tscn")

signal proj_changed()
@export var projectileLanded: int = 0

const MAX_PROJ_LAND: int = 3  # can be changed later

func create_projectile(playerNode: Node, playerDirection: Vector2, playerGP: Vector2) -> void:
	var Proj: Node = Global.mainNode.get_node("ProjectileGroup")
	var new_projectile: Area2D = projectile.instantiate()
	
	new_projectile.global_position = playerGP
	new_projectile.lock_on_to_player(playerDirection, playerNode, Proj)
	Proj.call_deferred("add_child", new_projectile)

func hitProjectile() -> void:
	if projectileLanded >= MAX_PROJ_LAND:
		projectileLanded = 0
		TrickManager.mainManager()
		get_parent().setPlayedCard()
	else:
		projectileLanded += 1
	proj_changed.emit(projectileLanded)
	
