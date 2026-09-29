extends Area2D

var cardList: Array

func setCardList(newList: Array):
	cardList = newList
	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print('New Cards: ', cardList)
		body.deckNode.addCards(cardList)
		body.setPendCard()
		queue_free()
