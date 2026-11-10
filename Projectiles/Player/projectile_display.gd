extends HBoxContainer

var empty_texture = preload("res://Assets/Sprite/Player/emptyprojectile.png")
var hit_texture = preload("res://Assets/Sprite/Player/projectile.png")
var projectiles: Node = null

func _ready() -> void:
	projectiles = get_node('/root/Main/Player/ProjectileManager')
	projectiles.proj_changed.connect(update_display)

func update_display(projs: int):
	for i in get_child_count():
		if i <= projs:
			get_child(i).texture = empty_texture
		else:
			get_child(i).texture = hit_texture
			
	
