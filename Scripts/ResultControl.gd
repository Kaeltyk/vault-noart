class_name ResultControl
extends Control

@onready var m_resultLabel:Label = $TextureRect/Label_Result
@onready var m_scoreValueLabel:Label = $TextureRect/Label_ScoreValue
@onready var m_newGameButton:Button = $TextureRect/Button_ScoreNewGame

var vaultGame:VaultGame

func _ready() -> void:
	var _result:int = m_newGameButton.pressed.connect(_on_newGameButton_pressed)

func setup(game:VaultGame) -> void:
	vaultGame = game
	Helpers.disable_and_hide_node(self)

func show_result(isSuccess:bool, score:float) -> void:
	Helpers.enable_and_show_node(self)
	m_resultLabel.text = "Success" if isSuccess else "Fail"
	m_scoreValueLabel.text = "%2.1f" % (score*100.0)

func hide_result() -> void:
	Helpers.disable_and_hide_node(self)

func _on_newGameButton_pressed() -> void:
	Helpers.disable_and_hide_node(self)
	vaultGame.new_game_same_size()
