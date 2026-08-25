extends Node

const suits: Array = [
	'Spades', 
	'Diamonds', 
	'Hearts',
	'Clubs']

const ranks: Array = [
	'2', 
	'3', 
	'4', 
	'5', 
	'6', 
	'7', 
	'8', 
	'9', 
	'10', 
	'J', 
	'Q', 
	'K', 
	'A']
	
func setCards(newCard: Node, cardDict: Dictionary, cardNodes: Dictionary) -> void:
	for card in cardDict:
		if cardDict[card] == null:
			cardDict[card] = newCard
			changeCardSprite(cardNodes[card], cardDict[card])
			break
			
	
func moveUpCards(cardDict: Dictionary, cardNodes: Dictionary) -> void:
	var pastKey = 'Card1'
	var currentKey
	for key in range(2, len(cardDict) + 1):
		currentKey = 'Card' + str(key)
		cardDict[pastKey] = cardDict[currentKey]
		changeCardSprite(cardNodes[pastKey],cardDict[pastKey])
		cardDict[currentKey] = null
		pastKey = currentKey
	
func checkSpace(cardDict: Dictionary) -> bool:
	var hasSpace: bool = false
	for card in cardDict:
		if cardDict[card] == null:
			hasSpace = true
	return hasSpace

func changeCardSprite(cardNode: Node, newCard: Node) -> void:
	var cardSuit: Node = cardNode.get_node("Suit")
	var cardRankTL: Node = cardNode.get_node("RankTopLeft")
	var cardRankBR: Node = cardNode.get_node("RankBotRight")
	cardSuit.show()
	cardRankTL.show()
	cardRankBR.show()
	
	cardSuit.frame = CardData.suits.find(newCard.suit)
	cardRankTL.frame = CardData.ranks.find(newCard.rank)
	cardRankBR.frame = CardData.ranks.find(newCard.rank)
	
func hideCards(cardNode: Node) -> void:
	var cardSuit: Node = cardNode.get_node("Suit")
	var cardRankTL: Node = cardNode.get_node("RankTopLeft")
	var cardRankBR: Node = cardNode.get_node("RankBotRight")
	cardSuit.hide()
	cardRankTL.hide()
	cardRankBR.hide()
