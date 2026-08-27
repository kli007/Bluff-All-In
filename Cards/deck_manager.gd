extends Node

var cardDict: Dictionary = {} #This holds all the scenes for each individual card, never changes
var activeArray: Array = [] # This hold the name of current cards in deck, changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for suit in CardData.suits:
		for rank in CardData.ranks:
			var newName = suit + rank
			cardDict[newName] = {'rank': rank, 'suit': suit}
	setNewDeck()

func setNewDeck() -> void:
	randomize()
	activeArray = Array(cardDict.keys())
	activeArray.shuffle()

func moveCard() -> Dictionary:
	var transferCard = cardDict[activeArray.pop_front()]
	return transferCard
	
func playCard(pendNodes: Array) -> Dictionary:
	var transferCard = {'rank': pendNodes[0].rank, 'suit': pendNodes[0].suit}
	CardData.hideCards(pendNodes[0])
	return transferCard
