class_name Cell
extends NinePatchRect

@export var m_unsetLabel:Label
@export var m_setLabel:Label
@export var m_guessLabel:Label
@export var m_button:Button

var game:VaultGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(m_unsetLabel != null, "Cell missing its unset label")
	assert(m_setLabel != null, "Cell missing its set label")
	assert(m_guessLabel != null, "Cell missing its guess label")
	assert(m_button != null, "Cell missing its button")
	Helpers.enable_and_show_node(m_unsetLabel)
	Helpers.disable_and_hide_node(m_setLabel)
	Helpers.disable_and_hide_node(m_guessLabel)
	#self.connect("mouse_entered", self, "_on_mouse_entered") /!\ Godot3
	var _result:int = m_button.mouse_entered.connect(_on_mouse_entered)
	_result = m_button.mouse_exited.connect(_on_mouse_exited)
	_result = m_button.gui_input.connect(_on_gui_input)

#func _gui_input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#print("I've been clicked D:")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_gui_input(event:InputEvent) -> void:
	if event is InputEventMouseButton:
		var eventMouseButton:InputEventMouseButton = event as InputEventMouseButton
		if eventMouseButton.button_index == MOUSE_BUTTON_RIGHT and eventMouseButton.pressed:
			game.on_cell_hacked(self)
		if eventMouseButton.button_index == MOUSE_BUTTON_LEFT and eventMouseButton.pressed:
			game.on_cell_clicked(self)
			#print(name+":"+event.as_text())
	pass

func _on_mouse_entered() -> void:
	game.on_cell_enter(self)
	#print("entered "+name)
	pass

func _on_mouse_exited() -> void:
	game.on_cell_exit(self)
	#print("exit "+name)
	pass

func set_guess(value:int) -> void:
	m_guessLabel.text = "%s" % value
	Helpers.enable_and_show_node(m_guessLabel)
	Helpers.disable_and_hide_node(m_unsetLabel)
	Helpers.disable_and_hide_node(m_setLabel)

func reset_guess() -> void:
	Helpers.enable_and_show_node(m_unsetLabel)
	Helpers.disable_and_hide_node(m_setLabel)
	Helpers.disable_and_hide_node(m_guessLabel)

func set_hacked(value:int) -> void:
	m_setLabel.text =  "%s" % value
	Helpers.disable_and_hide_node(m_guessLabel)
	Helpers.disable_and_hide_node(m_unsetLabel)
	Helpers.enable_and_show_node(m_setLabel)
	
