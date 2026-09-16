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
	
func checkHand(playedNodes: Array) -> void:
	var matches = checkHelper(playedNodes)
	if checkPairs(playedNodes, matches, 2):
		print('Two Pair')
	elif checkPairs(playedNodes, matches, 1):
		print('Pair')
	else:
		print('High Card')
		
func checkHelper(hand: Array) -> Dictionary: #we can reuse this code a bunch
	var nodeMax: int = hand.size()
	var matchingCards: Dictionary
	
	for key in nodeMax:
		var currentRank: String = hand[key].rank
		if matchingCards.has(currentRank):
			matchingCards[currentRank] += 1
		else:
			matchingCards[currentRank] = 1
	return matchingCards
	
func checkPairs(hand: Array, matches: Dictionary, max: int) -> bool:
	var currentPairs: int = 0
	for key in matches.keys():
		if matches[key] == 2:
			currentPairs += 1
			
	if currentPairs >= max:
		return true
	else:
		return false
		
func checkKinds(hand: Array) -> bool:
	return false

func checkStraight(hand: Array) -> bool:
	return false

func checkFlush(hand: Array) -> bool:
	return false
	
func checkFHouse(hand: Array) -> bool:
	return false
