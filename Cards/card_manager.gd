extends Node

var cardList = {} #This holds all the scenes for each individual card, never changes
var actList = [] # This hold the name of current cards in deck, changed
var card = preload("res://Cards/card_stats.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for suit in CardData.suits:
		for rank in CardData.ranks:
			var newName = suit + rank
			cardList[newName] = card.new()
			cardList[newName].setData(suit, rank)
			
	setNewDeck()
	#print(actList)
			
func setNewDeck() -> void:
	randomize()
	actList = Array(cardList.keys())
	actList.shuffle()
	
func moveCard():
	var transferCard = cardList[actList.pop_front()]
	#print(actList)
	return transferCard
	
func playCard(pendDict, nodeArray):
	var transferCard = pendDict['Card1']
	CardData.hideCards(nodeArray['Card1'])
	pendDict['Card1'] = null
	return transferCard
	
	

	
