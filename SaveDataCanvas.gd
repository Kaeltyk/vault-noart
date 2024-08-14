class_name SaveDataCanvas
extends CanvasLayer

@export var m_saveDataStat:PackedScene
@export var m_saveDataStatContainer:VBoxContainer
@export var m_clearSaveButton:Button

var saveDataStats:Array[SaveDataStat] = []

func _ready() -> void:
	var dataCount:int = SaveManager.saveData.gamesCount.size()
	for i:int in range(0, dataCount):
		var newSaveDataStat:SaveDataStat = m_saveDataStat.instantiate()
		saveDataStats.append( newSaveDataStat)
		m_saveDataStatContainer.add_child(newSaveDataStat)
	var _result:int = m_clearSaveButton.pressed.connect(_on_clearSaveButton_pressed)

func update_stats() -> void:
	var dataCount:int = saveDataStats.size()
	var saveData:SaveResource = SaveManager.saveData
	for i:int in range(0, dataCount):
		saveDataStats[i].setup_stats_display(i+3, saveData.gamesCount[i], saveData.gamessuccessCount[i], saveData.gamesScoreAvg[i])

func _on_clearSaveButton_pressed() -> void:
	#TODO: should popup a confirmation window
	SaveManager.clear_save()
	update_stats()

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
