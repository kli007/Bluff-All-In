extends Label
var playerCombo: Node = null

func _ready() -> void:
	playerCombo = get_node("/root/Main/Player")
	playerCombo.comboChanged.connect(_on_player_combo_changed)
	playerCombo.projNode.comboChanged.connect(_on_player_combo_changed)
	text = "Last Action:"
	
	
func _on_player_combo_changed(playedHand: String) -> void:
	text = "Last Action: " + playedHand
