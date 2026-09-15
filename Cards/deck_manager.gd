extends Node

var cardDict: Dictionary = {} #This holds all the scenes for each individual card, never changes
var activeArray: Array = [] # This hold the name of current cards in deck, changed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for suit in CardData.suits:
		for rank in CardData.ranks:
			var newName: String = suit + rank
			cardDict[newName] = {'rank': rank, 'suit': suit}
	setNewDeck()

func setNewDeck() -> void:
	randomize()
	activeArray = Array(cardDict.keys())
	activeArray.shuffle()

func moveCard() -> Dictionary:
	var transferCard: Dictionary = cardDict[activeArray.pop_front()]
	return transferCard
	
func playCard(pendNodes: Array) -> Dictionary:
	var transferCard: Dictionary = {'rank': pendNodes[0].rank, 'suit': pendNodes[0].suit}
	CardData.hideCards(pendNodes[0])
	return transferCard
	
func checkDeck() -> bool:
	return activeArray.is_empty()
	
func deleteDeck() -> void:
	print('deleted deck')
	activeArray = []
	
func checkHand(playedNodes: Array) -> String:
	return 'hello'

func checkTPair(hand: Array) -> bool:
	var nodeMax: int = hand.size()
	var isTPair: bool = false
	var pairCards: Dictionary
	for key in range(nodeMax - 1):
		var currentCard: String = hand[key].rank
		var nextKey: int = key + 1
		for next in hand.slice(nextKey, nodeMax):
			var nextCard = next.rank
			if currentCard == nextCard and currentCard != '':
				pairCards[currentCard] = 0
	if pairCards.size() >= 2:
		isTPair = true
	return isTPair
	
func checkPair(hand: Array) -> bool:
	var nodeMax: int = hand.size()
	var isPair: bool = false
	for key in range(nodeMax - 1):
		var currentCard: String = hand[key].rank
		var nextKey: int = key + 1
		for next in hand.slice(nextKey, nodeMax):
			var nextCard = next.rank
			if currentCard == nextCard and currentCard != '':
				isPair = true
	return isPair
