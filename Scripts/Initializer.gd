class_name Initializer
extends Node2D

# Could be replaced by using unique names & %name in code? (not sure how is handled the _ready order?)
@onready var m_overlayCanvas:CanvasLayer = $CanvasLayer_Overlay
@onready var m_titleCanvas:CanvasLayer = $CanvasLayer_Title
@onready var m_backgroundCanvas:CanvasLayer = $CanvasLayer_Background
@onready var m_menuCanvas:Menu = $CanvasLayer_Menu
@onready var m_rulesCanvas:CanvasLayer = $CanvasLayer_Rules
@onready var m_creditsCanvas:CanvasLayer = $CanvasLayer_Credits
@onready var m_gameCanvas:CanvasLayer = $CanvasLayer_Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Helpers.enable_and_show_node(m_overlayCanvas)
	Helpers.enable_and_show_node(m_titleCanvas)
	Helpers.disable_and_hide_node(m_backgroundCanvas)
	Helpers.disable_and_hide_node(m_menuCanvas)
	Helpers.disable_and_hide_node(m_rulesCanvas)
	Helpers.disable_and_hide_node(m_creditsCanvas)
	Helpers.disable_and_hide_node(m_gameCanvas)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
