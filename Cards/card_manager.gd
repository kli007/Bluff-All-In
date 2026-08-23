extends Node

var cardDict: Dictionary = {} #This holds all the scenes for each individual card, never changes
var activeArray: Array = [] # This hold the name of current cards in deck, changed
const card: Script = preload("res://Cards/card_stats.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for suit in CardData.suits:
		for rank in CardData.ranks:
			var newName = suit + rank
			cardDict[newName] = card.new()
			cardDict[newName].setData(suit, rank)
			
	setNewDeck()
	#print(actList)
			
func setNewDeck() -> void:
	randomize()
	activeArray = Array(cardDict.keys())
	activeArray.shuffle()
	
func moveCard() -> Node:
	var transferCard = cardDict[activeArray.pop_front()]
	#print(actList)
	return transferCard
	
func playCard(pendDict: Dictionary, nodeDict: Dictionary) -> Node:
	var transferCard = pendDict['Card1']
	CardData.hideCards(nodeDict['Card1'])
	pendDict['Card1'] = null
	return transferCard
	
	

	
