extends ColorRect

@export var m_initialTimer:float = 0.5
@export var m_initializer:Initializer

var timer:float

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(m_initializer != null, "Missing m_initializer on Overlay")
	timer = maxf(m_initialTimer, 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame (ms)
func _process(delta):
	if ( timer > 0.0 ):
		timer -= delta;
		timer = clampf(timer, 0.0, 1.0)
		var overlayColor:Color = get_color();
		overlayColor.a = timer/m_initialTimer
		set_color(overlayColor)
	else:
		Helpers.disable_and_hide_node(m_initializer.m_overlayCanvas)
