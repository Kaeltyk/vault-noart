class_name SaveDataStat
extends TextureRect

@onready var sizeValueLabel:Label = $HBoxContainer/Label_SizeValue
@onready var playedValueLabel:Label = $HBoxContainer/Label_PlayedValue
@onready var successValueLabel:Label = $HBoxContainer/Label_SuccessValue
@onready var avgScoreValueLabel:Label = $HBoxContainer/Label_AvgScoreValue

func setup_stats_display(gamesize:int, played:int, success:int, avgScore:float) -> void:
	sizeValueLabel.text = "%sx%s" % [gamesize, gamesize]
	playedValueLabel.text = "%s" % played
	if ( played > 0 ):
		successValueLabel.text = "%s / %s" % [success, played]
	else:
		successValueLabel.text = "0 / 0"
	avgScoreValueLabel.text = "%2.1f" % (avgScore*100.0)


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
