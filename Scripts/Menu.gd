extends CanvasLayer

@export var m_rulesButton:Button
@export var m_new3x3Button:Button
@export var m_new4x4Button:Button
@export var m_new5x5Button:Button
@export var m_initializer:Initializer
@export var m_vaultGame:VaultGame

var areRulesDisplayed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(m_rulesButton != null, "Menu missing m_rulesButton")
	assert(m_initializer != null, "Menu missing m_initializer")
	assert(m_vaultGame != null, "Menu missing m_vaultGame")
	var _result:int = m_rulesButton.pressed.connect(_on_rulesButton_pressed)
	_result = m_new3x3Button.pressed.connect(_on_new3x3Button_pressed)
	_result = m_new4x4Button.pressed.connect(_on_new4x4Button_pressed)
	_result = m_new5x5Button.pressed.connect(_on_new5x5Button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_rulesButton_pressed() -> void:
	if ( areRulesDisplayed ):
		HideRules()
	else:
		ShowRules()

func _on_new3x3Button_pressed() -> void: start_new_game(3,3)
func _on_new4x4Button_pressed() -> void: start_new_game(4,4)
func _on_new5x5Button_pressed() -> void: start_new_game(5,5)

func start_new_game(sizex:int, sizey:int) -> void:
	print("New Game!")
	Helpers.enable_and_show_node(m_vaultGame)
	Helpers.disable_and_hide_node(m_initializer.m_menuCanvas)
	m_vaultGame.start_new_game(sizex, sizey)
	

func ShowRules() -> void:
	Helpers.enable_and_show_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = true

func HideRules() -> void:
	Helpers.disable_and_hide_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = false
