class_name Menu
extends CanvasLayer

@onready var m_rulesButton:Button = $Control/HBoxContainer2/Button_Rules
@onready var m_creditsButton:Button = $Control/HBoxContainer2/Button_Credits
@onready var m_saveDataButton:Button = $Control/HBoxContainer2/Button_SaveData
@onready var m_exitButton:Button = $Control/HBoxContainer2/Button_Exit
@onready var m_new3x3Button:Button = $Control/HBoxContainer/Button_3x3
@onready var m_new4x4Button:Button = $Control/HBoxContainer/Button_4x4
@onready var m_new5x5Button:Button = $Control/HBoxContainer/Button_5x5
@onready var m_new6x6Button:Button = $Control/HBoxContainer/Button_6x6
@onready var m_new7x7Button:Button = $Control/HBoxContainer/Button_7x7
@onready var m_new8x8Button:Button = $Control/HBoxContainer/Button_8x8
@export var m_initializer:Initializer
@export var m_vaultGame:VaultGame

var areRulesDisplayed:bool = false
var areCreditsDisplayed:bool = false
var areSaveDatasDisplayed:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(m_rulesButton != null, "Menu missing m_rulesButton")
	assert(m_initializer != null, "Menu missing m_initializer")
	assert(m_vaultGame != null, "Menu missing m_vaultGame")
	var _result:int = m_rulesButton.pressed.connect(_on_rulesButton_pressed)
	_result = m_creditsButton.pressed.connect(_on_creditsButton_pressed)
	_result = m_saveDataButton.pressed.connect(_on_saveDataButton_pressed)
	_result = m_new3x3Button.pressed.connect(_on_new3x3Button_pressed)
	_result = m_new4x4Button.pressed.connect(_on_new4x4Button_pressed)
	_result = m_new5x5Button.pressed.connect(_on_new5x5Button_pressed)
	_result = m_new6x6Button.pressed.connect(_on_new6x6Button_pressed)
	_result = m_new7x7Button.pressed.connect(_on_new7x7Button_pressed)
	_result = m_new8x8Button.pressed.connect(_on_new8x8Button_pressed)
	_result = m_exitButton.pressed.connect(_on_exitButton_pressed)

func open_menu() -> void:
	Helpers.enable_and_show_node(self)

func close_menu() -> void:
	# close any potential page that could be opened
	if ( areRulesDisplayed ):
		hide_rules()
	if ( areCreditsDisplayed ):
		hide_credits()
	if ( areSaveDatasDisplayed ):
		hide_saveDatas()
	Helpers.disable_and_hide_node(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func _on_rulesButton_pressed() -> void:
	if ( areRulesDisplayed ):
		hide_rules()
	else:
		show_rules()

func _on_creditsButton_pressed() -> void:
	if ( areCreditsDisplayed ):
		hide_credits()
	else:
		show_credits()

func _on_saveDataButton_pressed() -> void:
	if ( areSaveDatasDisplayed ):
		hide_saveDatas()
	else:
		show_saveDatas()

func _on_exitButton_pressed() -> void:
	get_tree().quit()

func _on_new3x3Button_pressed() -> void: start_new_game(3,3)
func _on_new4x4Button_pressed() -> void: start_new_game(4,4)
func _on_new5x5Button_pressed() -> void: start_new_game(5,5)
func _on_new6x6Button_pressed() -> void: start_new_game(6,6)
func _on_new7x7Button_pressed() -> void: start_new_game(7,7)
func _on_new8x8Button_pressed() -> void: start_new_game(8,8)

func start_new_game(sizex:int, sizey:int) -> void:
	print("New Game!")
	Helpers.enable_and_show_node(m_vaultGame)
	Helpers.disable_and_hide_node(m_initializer.m_menuCanvas)
	m_vaultGame.start_new_game(sizex, sizey)
	

func show_rules() -> void:
	if ( areCreditsDisplayed ):hide_credits()
	if ( areSaveDatasDisplayed ):hide_saveDatas()
	Helpers.enable_and_show_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = true

func hide_rules() -> void:
	Helpers.disable_and_hide_node(m_initializer.m_rulesCanvas)
	areRulesDisplayed = false
	m_rulesButton.release_focus()

func show_credits() -> void:
	if ( areRulesDisplayed ):hide_rules()
	if ( areSaveDatasDisplayed ):hide_saveDatas()
	Helpers.enable_and_show_node(m_initializer.m_creditsCanvas)
	areCreditsDisplayed = true

func hide_credits() -> void:
	Helpers.disable_and_hide_node(m_initializer.m_creditsCanvas)
	areCreditsDisplayed = false
	m_creditsButton.release_focus()

func show_saveDatas() -> void:
	if ( areRulesDisplayed ):hide_rules()
	if ( areCreditsDisplayed ):hide_credits()
	Helpers.enable_and_show_node(m_initializer.m_saveDataCanvas)
	m_initializer.m_saveDataCanvas.update_stats()
	areSaveDatasDisplayed = true

func hide_saveDatas() -> void:
	Helpers.disable_and_hide_node(m_initializer.m_saveDataCanvas)
	areSaveDatasDisplayed = false
	m_saveDataButton.release_focus()
