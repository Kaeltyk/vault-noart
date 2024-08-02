extends Label

@export var m_initializer:Initializer

func _ready() -> void:
	assert(m_initializer != null, "Missing m_initializer on Title")
	
func _input(event:InputEvent) -> void:
	if (event is InputEventMouseButton) && (event.is_released()):
		# print(event.as_text())
		Helpers.enable_and_show_node(m_initializer.m_backgroundCanvas)
		Helpers.enable_and_show_node(m_initializer.m_menuCanvas)
		Helpers.disable_and_hide_node(m_initializer.m_titleCanvas)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
