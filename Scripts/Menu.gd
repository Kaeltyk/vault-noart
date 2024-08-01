extends CanvasLayer

@export var m_rulesButton:Button
@export var m_newGameButton:Button
@export var m_initializer:Initializer
@export var m_vaultGame:VaultGame

var areRulesDisplayed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(m_rulesButton != null, "Menu missing m_rulesButton")
	assert(m_newGameButton != null, "Menu missing m_newGameButton")
	assert(m_initializer != null, "Menu missing m_initializer")
	assert(m_vaultGame != null, "Menu missing m_vaultGame")
	var _result:int = m_rulesButton.pressed.connect(_on_rulesButton_pressed)
	_result = m_newGameButton.pressed.connect(_on_newGameButton_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_rulesButton_pressed() -> void:
	if ( areRulesDisplayed ):
		HideRules()
	else:
		ShowRules()
	
func _on_newGameButton_pressed() -> void:
	print("New Game!")
	Helpers.enable_and_show_node(m_vaultGame)
	Helpers.disable_and_hide_node(m_initializer.m_menuCanvas)
	m_vaultGame.start_new_game(5,5)
	

func ShowRules() -> void:
	Helpers.enable_and_show_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = true

func HideRules() -> void:
	Helpers.disable_and_hide_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = false
