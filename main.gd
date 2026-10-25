extends Node


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	Global.mainNode = self
	Global.pendNodes = get_node("HUD/PendCardsControl/PendCards").get_children()
	Global.playedNodes = get_node("HUD/UserUIControl/PlayedCards").get_children()
