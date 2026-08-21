extends Node2D
var pendDict = {'Card1': null,'Card2': null, 'Card3': null, 
	'Card4': null, 'Card5': null, 'Card6': null, 'Card7': null}

func setCards(newCard):
	for card in pendDict:
		if pendDict[card] == null:
			pendDict[card] = newCard
			print(pendDict[card].suit)
			print(pendDict[card].rank)
			break

	
func moveUpCards() -> void:
	print(1)
	
func checkSpace() -> bool:
	var hasSpace = false
	for card in pendDict:
		if pendDict[card] == null:
			hasSpace = true
	
	return hasSpace
