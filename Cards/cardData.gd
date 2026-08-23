extends Node

const suits = [
	'Spades', 
	'Diamonds', 
	'Hearts',
	'Clubs']

const ranks = [
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
	
func setCards(newCard, cardDict, cardNodes):
	for card in cardDict:
		if cardDict[card] == null:
			cardDict[card] = newCard
			changeCardSprite(cardNodes[card], cardDict[card])
			break
			
	
func moveUpCards() -> void:
	print(1)
	
func checkSpace(cardDict) -> bool:
	var hasSpace = false
	for card in cardDict:
		if cardDict[card] == null:
			hasSpace = true
	return hasSpace

func changeCardSprite(cardNode, newCard):
	var cardSuit = cardNode.get_node("Suit")
	var cardRankTL = cardNode.get_node("RankTopLeft")
	var cardRankBR = cardNode.get_node("RankBotRight")
	cardSuit.show()
	cardRankTL.show()
	cardRankBR.show()
	
	cardSuit.frame = CardData.suits.find(newCard.suit)
	cardRankTL.frame = CardData.ranks.find(newCard.rank)
	cardRankBR.frame = CardData.ranks.find(newCard.rank)
		
func hideCards(cardNode):
	var cardSuit = cardNode.get_node("Suit")
	var cardRankTL = cardNode.get_node("RankTopLeft")
	var cardRankBR = cardNode.get_node("RankBotRight")
	cardSuit.hide()
	cardRankTL.hide()
	cardRankBR.hide()
