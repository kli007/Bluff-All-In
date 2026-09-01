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
	
func setCards(newCard: Dictionary, cardNodes: Array) -> void:
	for card in cardNodes:
		if card.checkData():
			card.setData(newCard['suit'], newCard['rank'])
			changeCardSprite(card)
			break
	
func moveUpCards(cardNodes: Array) -> void:
	var lastCard: Node = cardNodes[6]
	var currentCard: Node
	for key in (len(cardNodes) - 1):
		currentCard = cardNodes[key]
		currentCard.setData(cardNodes[key + 1]['suit'], cardNodes[key + 1]['rank'])
		if currentCard.checkData():
			hideCards(currentCard)
		else:
			changeCardSprite(currentCard)
	lastCard.resetData()
	hideCards(lastCard)

func checkSpace(cardNodes: Array) -> bool:
	var hasSpace: bool = false
	for card in cardNodes:
		if card.checkData():
			hasSpace = true
	return hasSpace
	
func checkEmpty(cardNodes: Array):
	var hasSpace: bool = true
	for card in cardNodes:
		if not card.checkData():
			hasSpace = false
	return hasSpace
	
func changeCardSprite(cardNode: Node) -> void:
	var cardSuit: Node = cardNode.get_node("Suit")
	var cardRankTL: Node = cardNode.get_node("RankTopLeft")
	var cardRankBR: Node = cardNode.get_node("RankBotRight")
	cardSuit.show()
	cardRankTL.show()
	cardRankBR.show()
	
	cardSuit.frame = CardData.suits.find(cardNode.suit)
	cardRankTL.frame = CardData.ranks.find(cardNode.rank)
	cardRankBR.frame = CardData.ranks.find(cardNode.rank)
	
func hideCards(cardNode: Node) -> void:
	var cardSuit: Node = cardNode.get_node("Suit")
	var cardRankTL: Node = cardNode.get_node("RankTopLeft")
	var cardRankBR: Node = cardNode.get_node("RankBotRight")
	cardSuit.hide()
	cardRankTL.hide()
	cardRankBR.hide()
	cardNode.rank = ''
	cardNode.suit = ''
	
func showdownCards(playedNodes: Array) -> void:
	for card in playedNodes:
		hideCards(card)
		card.resetData()
