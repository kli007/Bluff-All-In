extends Node

signal comboChanged
var lastPlayedHand: String = ''

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
	if checkStraight(playedNodes) and checkFlush(playedNodes):
		lastPlayedHand = 'Straight Flush'
	elif checkKinds(matches, 4):
		lastPlayedHand = '4 of a Kind'
	elif checkKinds(matches, 3) and checkPairs(matches, 1):
		lastPlayedHand = 'Full House'
	elif checkFlush(playedNodes):
		lastPlayedHand = 'Flush'
	elif checkStraight(playedNodes):
		lastPlayedHand = 'Straight'
	elif checkKinds(matches, 3):
		lastPlayedHand = '3 of a Kind'
	elif checkPairs(matches, 2):
		lastPlayedHand = 'Two Pair'
	elif checkPairs(matches, 1):
		lastPlayedHand = 'Pair'
	else:
		lastPlayedHand = 'High Card'
	comboChanged.emit()
		
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
	
func checkPairs(matches: Dictionary, needed: int) -> bool:
	var currentPairs: int = 0
	for key in matches.keys():
		if matches[key] == 2:
			currentPairs += 1
			
	if currentPairs >= needed:
		return true
	else:
		return false
		
func checkKinds(matches: Dictionary, needed: int) -> bool:
	var isKinds: bool = false
	for key in matches.keys():
		if matches[key] == needed:
			isKinds = true
			break
	return isKinds

func checkStraight(hand: Array) -> bool:
	var isStraight: bool = true
	var rankArray: Array = []
	for card in hand:
		var newRank: String = card.rank
		if newRank != '':
			rankArray.append(CardData.ranks.find(newRank))
			
	if rankArray.size() < 5:
		isStraight = false
	else:
		rankArray.sort()
		for key in range(rankArray.size() - 1):
			if rankArray[key] + 1 != rankArray[key + 1]:
				isStraight = false
				break
	return isStraight

func checkFlush(hand: Array) -> bool:
	var isFlush: bool = true
	for key in range(hand.size() - 1):
		if hand[key].suit != hand[key + 1].suit:
			isFlush = false
			break
	return isFlush
