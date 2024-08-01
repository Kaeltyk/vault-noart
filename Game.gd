class_name VaultGame
extends CanvasLayer

@export var m_cellScene:PackedScene
@export var m_boardControl:Control

@export var boardXSize:int = 4
@export var boardYSize:int = 4

class CellData:
	var cellRef:Cell
	var cellId:int
	var value:int
	var codeStr:String
	var codeSequence:Array[int] = []
	func _init(_cellRef:Cell, _cellId:int, _value:int) -> void:
		self.cellRef = _cellRef
		self.cellId = _cellId
		self.value = _value
		self.codeStr = ""
	
var currentHoveredCell:Cell
var allCellDatas:Array[CellData] = []
#var codeValues:Array[int] = []
#var hackedCodes:Array[String] = []

# Called when the node enters the scene tree for the first time.
#func _ready():
	#print("Game Ready!!")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func start_new_game() -> void:
	print("Starting new game!")
	#instantiate a grid to test
	var xtopOffset:float = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset:float = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	for x:int in range(boardXSize):
		for y:int in range(boardYSize):
			var newCell:Cell = m_cellScene.instantiate()
			newCell.game = self
			newCell.global_position = Vector2(xtopOffset + x*64.0,ytopOffset + y*64.0)
			
			var code:int = randi_range(0, 9)
			var newCellData:CellData = CellData.new(newCell, x*boardYSize+y, code)

			allCellDatas.append(newCellData)
			print("code value for cell %s is %s" % [(x*boardYSize+y), code])

			m_boardControl.add_child(newCell)
	#var _result:int = hackedCodes.resize(allCells.size())


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
		currentHoveredCell.reset_guess()

func get_cell_id(cell:Cell) -> int:
	for cellData:CellData in allCellDatas:
		if cellData.cellRef == cell:
			return cellData.cellId
	assert(false, "get_cell_id fail!")
	return -1
	
func on_cell_hacked(hackedCell:Cell) -> void:
	var cellId:int = get_cell_id(hackedCell)
	var isAlreadyHacked:bool = (allCellDatas[cellId].codeStr != null && allCellDatas[cellId].codeStr != "")
	if isAlreadyHacked:
		print("cell %d already hacked" % cellId)
		return
	generate_code_for_cell(cellId)
	hackedCell.set_hacked(allCellDatas[cellId].value)

func on_cell_clicked(hackedCell:Cell) -> void:
	pass

func generate_code_for_cell(cellId:int) -> void:
	# first get cell quadrant so we can get target quadrant
	# then walk random path toward target & store digits for the code
	pass
