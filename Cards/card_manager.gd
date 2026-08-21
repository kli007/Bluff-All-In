extends Node

var cardList = {} #This holds all the scenes for each individual card, never changes
var actList = [] # This hold the name of current cards in deck, changed
var card = preload("res://Cards/cardTemplate.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var suits = ['Spade', 'Diamond', 'Club', 'Heart']
	var ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
	
	for suit in suits:
		for rank in ranks:
			var newName = suit + rank
			cardList[newName] = card.instantiate()
			cardList[newName].setData(suit, rank)
			
	setNewDeck()
	print(actList)
			
func setNewDeck() -> void:
	randomize()
	actList = Array(cardList.keys())
	actList.shuffle()
	
func moveCard():
	var transferCard = cardList[actList.pop_front()]
	print(actList)
	return transferCard
	
