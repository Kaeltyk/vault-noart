class_name ResultControl
extends Control

@export var m_resultLabel:Label
@export var m_scoreValueLabel:Label
@export var m_newGameButton:Button

var vaultGame:VaultGame

func _ready() -> void:
	var _result:int = m_newGameButton.pressed.connect(_on_newGameButton_pressed)

func setup(game:VaultGame) -> void:
	vaultGame = game
	Helpers.disable_and_hide_node(self)

func open_result(isSuccess:bool, score:float) -> void:
	Helpers.enable_and_show_node(self)
	m_resultLabel.text = "Success" if isSuccess else "Fail"
	m_scoreValueLabel.text = "%2.1f" % (score*100.0)

func close_result() -> void:
	Helpers.disable_and_hide_node(self)

func _on_newGameButton_pressed() -> void:
	Helpers.disable_and_hide_node(self)
	vaultGame.new_game_same_size()
	
# Constructor?
#func _init() -> void:
	 #pass # Replace with function body.

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	 #pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame (ms)
#func _process(_delta: float) -> void:
	 #pass

