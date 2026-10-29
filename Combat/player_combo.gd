extends Label

var player: Node = null
var lastActions: Array
var isPlayHand: bool = false
var comboChain: float = 0.0
var rankMultiplier: float = 1.0 

@onready var rankLabel: Label = $RankLabel
@onready var comboTime: Timer = $ComboTimer
@onready var bufferTime: Timer = $BufferTimer
@onready var bar: ProgressBar = $ComboTimeBar

const DISPLAY_LIMIT: int = 5

func _ready() -> void:
	player = get_node("/root/Main/Player")
	player.needMultiplier.connect(_pop_combat_value)
	CombatManager.enemy_hit.connect(_on_player_combo_changed)
	CombatManager.accumDmgChange.connect(_check_rank)
	text = "Combo: "
	
func _process(_delta: float) -> void:
	bar.value = comboTime.time_left
	
func _on_player_combo_changed(attack: String) -> void:
	var display: String = CombatManager.ATTACKS[attack]["display"]
	increaseChain()
	playCardOnHit(display)
	CombatManager.recoilBody(player, attack)
	lastActions.append(display)
	text = 'Combo: ' + str(int(comboChain))
	for act in lastActions.slice(-DISPLAY_LIMIT):
		text += '\n-' + act
	comboTime.start()
	comboTime.paused = true
	bufferTime.start()
	
func _on_combo_timer_timeout() -> void:
	text = 'Combo: '
	rankLabel.text = ''
	CombatManager.resetAccumDmg()
	lastActions.clear()

func _on_buffer_timer_timeout() -> void:
	comboTime.paused = false
	
func _pop_combat_value() -> void:
	CombatManager.setComboMultiplier(comboChain)
	comboChain = 0.0
	
func increaseChain() -> void:
	comboChain += 1.0 * rankMultiplier
	
func _check_rank() -> void: 
	var newRank: String = CombatManager.getRankText()
	rankLabel.text = newRank
	rankMultiplier = CombatManager.getRankMultiplier(newRank)
	
func playCardOnHit(damageDisplay: String) -> void:
	var attackKeys = CombatManager.ATTACKS.keys().slice(0, 6)
	for key in attackKeys:
		if damageDisplay ==  CombatManager.ATTACKS[key]['display']:
			player.setPlayedCard()
			return
