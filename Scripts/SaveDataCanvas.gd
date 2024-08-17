class_name SaveDataCanvas
extends CanvasLayer

@export var m_saveDataStat:PackedScene
@onready var m_saveDataStatContainer:VBoxContainer = $Control/NinePatchRect/VBoxContainer
@onready var m_clearSaveButton:Button = $Control/NinePatchRect/Button_ClearSave

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
		saveDataStats[i].setup_stat_display(i+3, saveData.gamesCount[i], saveData.gamessuccessCount[i], saveData.gamesScoreAvg[i])

func _on_clearSaveButton_pressed() -> void:
	#TODO: should popup a confirmation window
	SaveManager.clear_save()
	update_stats()
