extends Label
var playerCombo: Node = null

func _ready() -> void:
	playerCombo = get_node("/root/Main/Player/DeckManager")
	playerCombo.comboChanged.connect(_on_player_combo_changed)
	text = "Last Played Combo"
	
	
func _on_player_combo_changed() -> void:
	text = "Last Played Combo: " + playerCombo.lastPlayedHand
