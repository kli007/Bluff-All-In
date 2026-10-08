extends Label

var player: Node = null
var lastActions: Array
var isPlayHand: bool = false
var comboChain: float = 0.0
var rankMultiplier: float = 1.0 

@onready var rankLabel: Node = $RankLabel
@onready var comboTime: Node = $ComboTimer
@onready var bufferTime: Node = $BufferTimer
@onready var bar: Node = $ComboTimeBar

var combat = CombatManager

const DISPLAY_LIMIT: int = 5

func _ready() -> void:
	player = get_node("/root/Main/Player")
	player.needMultiplier.connect(_pop_combat_value)
	combat.enemy_hit.connect(_on_player_combo_changed)
	combat.accumDmgChange.connect(_check_rank)
	text = "Combo: "
	
func _process(_delta: float) -> void:
	bar.value = comboTime.time_left
	
func _on_player_combo_changed(playedHand: String) -> void:
	increaseChain()
	lastActions.append(playedHand)
	text = 'Combo: ' + str(int(comboChain))
	for act in lastActions.slice(-DISPLAY_LIMIT):
		text += '\n-' + act
	comboTime.start()
	comboTime.paused = true
	bufferTime.start()
	
func _on_combo_timer_timeout() -> void:
	text = 'Combo: '
	rankLabel.text = ''
	combat.resetAccumDmg()
	lastActions.clear()

func _on_buffer_timer_timeout() -> void:
	comboTime.paused = false
	
func _pop_combat_value() -> void:
	combat.setComboMultiplier(comboChain)
	comboChain = 0.0
	
func increaseChain() -> void:
	comboChain += 1.0 * rankMultiplier
	
func _check_rank() -> void: 
	var newRank: String = combat.getRankText()
	rankLabel.text = newRank
	rankMultiplier = combat.getRankMultiplier(newRank)
