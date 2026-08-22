extends Node2D
var pendDict = {'Card1': null,'Card2': null, 'Card3': null, 
	'Card4': null, 'Card5': null, 'Card6': null, 'Card7': null}

@onready var nodeArray = {'Card1': $Card1,'Card2': $Card2, 'Card3': $Card3, 
	'Card4': $Card4, 'Card5': $Card5, 'Card6': $Card6, 'Card7': $Card7}
	


func setCards(newCard):
	for card in pendDict:
		if pendDict[card] == null:
			pendDict[card] = newCard
			changeCardSprite(nodeArray[card], pendDict[card])
			break
			

	
func moveUpCards() -> void:
	print(1)
	
func checkSpace() -> bool:
	var hasSpace = false
	for card in pendDict:
		if pendDict[card] == null:
			hasSpace = true
	return hasSpace

func changeCardSprite(cardNode, newCard):
	cardNode.get_node("Suit").frame = CardData.suits.find(newCard.suit)
	cardNode.get_node("RankTopLeft").frame = CardData.ranks.find(newCard.rank)
	cardNode.get_node("RankBotRight").frame = CardData.ranks.find(newCard.rank)
