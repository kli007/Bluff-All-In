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
	var nodeMax: int = len(cardNodes)
	for key in range(nodeMax):
		var currentCard: Node = cardNodes[key]
		var nextKey: int = key + 1
		if currentCard == cardNodes.back():
			hideCards(currentCard)
		elif currentCard.checkData():
			for nextCard in cardNodes.slice(nextKey, nodeMax):
				if not nextCard.checkData():
					currentCard.setData(nextCard.suit, nextCard.rank)
					changeCardSprite(currentCard)
					hideCards(nextCard)
					break

func checkSpace(cardNodes: Array) -> int:
	var hasSpace: int = 0
	for card in cardNodes:
		if card.checkData():
			hasSpace += 1
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
	cardNode.resetData()
	
func showdownCards(playedNodes: Array) -> void:
	for card in playedNodes:
		hideCards(card)
