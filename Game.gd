class_name VaultGame
extends CanvasLayer

@export var m_cellScene:PackedScene
@export var m_boardControl:Control

@export var boardXSize:int = 4
@export var boardYSize:int = 4

var currentHoveredCell:Cell
var allCells = []

# Called when the node enters the scene tree for the first time.
#func _ready():
	#print("Game Ready!!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func start_new_game() -> void:
	print("Starting new game!")
	#instantiate a grid to test
	var xtopOffset = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	for x in range(boardXSize):
		for y in range(boardYSize):
			var newCell:Cell = m_cellScene.instantiate()
			newCell.game = self
			newCell.global_position = Vector2(xtopOffset + x*64,ytopOffset + y*64)
			allCells.append(newCell)
			m_boardControl.add_child(newCell)


func on_cell_enter(enteredCell: Cell):
	currentHoveredCell = enteredCell
	#print("on_cell_enter current cell: %s" % currentHoveredCell.name)


func on_cell_exit(exitedCell: Cell):
	if (exitedCell == currentHoveredCell):
		currentHoveredCell = null
	#if (currentHoveredCell != null):
		#print("on_cell_exit current cell: %s" % currentHoveredCell.name)
	#else:
		#print("on_cell_exit current cell: NULL")


func _input(event):
	#print(event.as_text())
	if (event.is_action_pressed("ui_zero")):
		update_guess_if_possible(0)
	elif (event.is_action_pressed("ui_one")):
		update_guess_if_possible(1)
	elif (event.is_action_pressed("ui_two")):
		update_guess_if_possible(2)
	elif (event.is_action_pressed("ui_three")):
		update_guess_if_possible(3)
	elif (event.is_action_pressed("ui_four")):
		update_guess_if_possible(4)
	elif (event.is_action_pressed("ui_five")):
		update_guess_if_possible(5)
	elif (event.is_action_pressed("ui_six")):
		update_guess_if_possible(6)
	elif (event.is_action_pressed("ui_seven")):
		update_guess_if_possible(7)
	elif (event.is_action_pressed("ui_eight")):
		update_guess_if_possible(8)
	elif (event.is_action_pressed("ui_nine")):
		update_guess_if_possible(9)
	elif (event.is_action_pressed("ui_guess_reset")):
		reset_guess_if_possible()

func update_guess_if_possible(value:int) -> void:
		if (currentHoveredCell != null):
			currentHoveredCell.set_guess(value)
	
func reset_guess_if_possible() -> void:
		if (currentHoveredCell != null):
			currentHoveredCell.resset_guess()
