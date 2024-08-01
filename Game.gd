class_name VaultGame
extends CanvasLayer

@export var m_cellScene:PackedScene
@export var m_boardControl:Control

var boardXSize:int = 3
var boardYSize:int = 3

#region CellData

class CellData:
	enum ECellState { UNSET, GUESS, SET }
	var cellState:ECellState = ECellState.UNSET
	var cellRef:Cell
	var cellId:int
	var value:int
	var guess:int = -1
	var codeStr:String = ""
	var codeSequence:Array[int] = []
	func _init(_cellRef:Cell, _cellId:int, _value:int) -> void:
		self.cellRef = _cellRef
		self.cellId = _cellId
		self.value = _value
	func set_guess(guessValue:int) -> void:
		self.guess = guessValue
		self.cellState = ECellState.GUESS
		self.cellRef.set_guess(guessValue)
	func reset_guess() -> void:
		self.guess = -1
		self.cellState = ECellState.UNSET
		self.cellRef.reset_guess()
	func set_hacked() -> void:
		self.cellState = ECellState.SET
		self.cellRef.set_hacked(value)

#endregion
	
var currentHoveredCell:Cell
var allCellDatas:Array[CellData] = []

# Called when the node enters the scene tree for the first time.
#func _ready():
	#print("Game Ready!!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func start_new_game(xsize:int = 4, ysize:int = 4) -> void:
	print("Starting new game")
	boardXSize = xsize
	boardYSize = ysize
	#instantiate a grid to test
	var xtopOffset:float = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset:float = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	for y:int in range(boardYSize):
		for x:int in range(boardXSize):
			var newCell:Cell = m_cellScene.instantiate()
			newCell.game = self
			newCell.global_position = Vector2(xtopOffset + x*64.0,ytopOffset + y*64.0)
			
			var code:int = randi_range(0, 9)
			var newCellData:CellData = CellData.new(newCell, y*boardXSize+x, code)

			allCellDatas.append(newCellData)
			#print("code value for cell %s is %s" % [(y*boardXSize+x), code])

			m_boardControl.add_child(newCell)
	#var _result:int = hackedCodes.resize(allCells.size())
	dbg_log_code()


func on_cell_enter(enteredCell: Cell) -> void:
	currentHoveredCell = enteredCell
	#print("on_cell_enter current cell: %s" % currentHoveredCell.name)


func on_cell_exit(exitedCell: Cell) -> void:
	if (exitedCell == currentHoveredCell):
		currentHoveredCell = null
	#if (currentHoveredCell != null):
		#print("on_cell_exit current cell: %s" % currentHoveredCell.name)
	#else:
		#print("on_cell_exit current cell: NULL")


func _input(event:InputEvent) -> void:
	#print(event.as_text())
	if (event.is_action_pressed("ui_zero")):		update_guess_if_possible(0)
	elif (event.is_action_pressed("ui_one")):		update_guess_if_possible(1)
	elif (event.is_action_pressed("ui_two")):		update_guess_if_possible(2)
	elif (event.is_action_pressed("ui_three")):		update_guess_if_possible(3)
	elif (event.is_action_pressed("ui_four")):		update_guess_if_possible(4)
	elif (event.is_action_pressed("ui_five")):		update_guess_if_possible(5)
	elif (event.is_action_pressed("ui_six")):		update_guess_if_possible(6)
	elif (event.is_action_pressed("ui_seven")):		update_guess_if_possible(7)
	elif (event.is_action_pressed("ui_eight")):		update_guess_if_possible(8)
	elif (event.is_action_pressed("ui_nine")):		update_guess_if_possible(9)
	elif (event.is_action_pressed("ui_guess_reset")):	reset_guess_if_possible()

func update_guess_if_possible(value:int) -> void:
	if (currentHoveredCell != null):
		var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		assert(currentHoveredCell == cellData.cellRef, "mismatch: allCellDatas[get_cell_id(cell)] != cell !!")
		var canSetGuess:bool = cellData.cellState != CellData.ECellState.SET
		if (canSetGuess):
			cellData.set_guess(value)
			#currentHoveredCell.set_guess(value)
	
func reset_guess_if_possible() -> void:
	if (currentHoveredCell != null):
		var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		var canResetGuess:bool = cellData.cellState != CellData.ECellState.SET
		if (canResetGuess):
			cellData.reset_guess()

func get_cell_id(cell:Cell) -> int:
	for i:int in range(allCellDatas.size()):
	#for cellData:CellData in allCellDatas:
		if (allCellDatas[i].cellRef == cell):
			return i
	assert(false, "get_cell_id fail!")
	return -1

func get_cellData_from_cell(cell:Cell) -> CellData:
	for cellData:CellData in allCellDatas:
		if (cellData.cellRef == cell):
			return cellData
	assert(false, "get_cellData_from_cell fail!")
	return null
	
func on_cell_hacked(hackedCell:Cell) -> void:
	var cellData:CellData = get_cellData_from_cell(hackedCell)
	var isAlreadyHacked:bool = cellData.cellState == CellData.ECellState.SET # (cellData.codeStr != null && cellData.codeStr != "")
	if (isAlreadyHacked):
		#print("cell %d already hacked" % cellData.cellId)
		return
	generate_code_for_cell(cellData)
	cellData.cellState = CellData.ECellState.SET
	cellData.set_hacked()

func on_cell_clicked(hackedCell:Cell) -> void:
	pass

func generate_code_for_cell(cellData:CellData) -> void:
	# first get cell quadrant so we can get target quadrant
	# then walk random path toward target & store digits for the code
	pass

func dbg_log_code() -> void:
	for y:int in range(boardYSize):
		var logstr:String = "code line %s: " % y;
		for x:int in range(boardXSize):
			var cellid:int = y*boardXSize+x
			logstr = logstr + "%s" % allCellDatas[cellid].value
		print(logstr)
	
