extends Label
var playerCombo: Node = null
var lastActions: Array
@onready var comboTime: Node = $ComboTimer
@onready var bufferTime: Node = $BufferTimer
@onready var bar: Node = $ComboTimeBar
const DISPLAY_LIMIT: int = 5

func _ready() -> void:
	playerCombo = get_node("/root/Main/Player")
	playerCombo.comboChanged.connect(_on_player_combo_changed)
	playerCombo.projNode.comboChanged.connect(_on_player_combo_changed)
	text = "Combo: "
	
func _process(delta: float) -> void:
	bar.value = comboTime.time_left
	
func _on_player_combo_changed(playedHand: String) -> void:
	lastActions.append(playedHand)
	text = 'Combo: ' + str(lastActions.size())
	for act in lastActions.slice(-DISPLAY_LIMIT):
		text += '\n-' + act
	comboTime.start()
	comboTime.paused = true
	bufferTime.start()
	
func _on_combo_timer_timeout() -> void:
	text = 'Combo: '
	lastActions.clear()

func _on_buffer_timer_timeout() -> void:
	comboTime.paused = false
