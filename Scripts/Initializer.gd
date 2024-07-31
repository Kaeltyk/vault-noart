class_name Initializer
extends Node2D

@export var m_overlayCanvas:CanvasLayer
@export var m_titleCanvas:CanvasLayer
@export var m_backgroundCanvas:CanvasLayer
@export var m_menuCanvas:CanvasLayer
@export var m_rulesCanvas:CanvasLayer
@export var m_gameCanvas:CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	Helpers.enable_and_show_node(m_overlayCanvas)
	Helpers.enable_and_show_node(m_titleCanvas)
	Helpers.disable_and_hide_node(m_backgroundCanvas)
	Helpers.disable_and_hide_node(m_menuCanvas)
	Helpers.disable_and_hide_node(m_rulesCanvas)
	Helpers.disable_and_hide_node(m_gameCanvas)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
