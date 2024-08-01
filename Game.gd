class_name VaultGame
extends CanvasLayer

@export var m_cellScene:PackedScene
@export var m_quadrantHighlightScene:PackedScene
@export var m_codeLabelScene:PackedScene
@export var m_boardControl:Control
@export var m_highlightControl:Control

var boardXSize:int = 3
var boardYSize:int = 7

#region CellData

enum ECellState { UNSET, GUESS, SET, INVALID }
class CellData:
	var cellState:ECellState = ECellState.INVALID
	var cellRef:Cell
	var cellId:int
	var cellx:int
	var celly:int
	var quadrant:int
	var oppositequadrant:int
	var value:int
	var guess:int = -1
	var codeStr:String = ""
	var codeSequence:Array[int] = []
	func _init(_cellRef:Cell, _cellx:int, _celly:int, _cellId:int, _value:int, _quadrant:int, _oppositequadrant:int) -> void:
		self.cellRef = _cellRef
		self.cellx = _cellx
		self.celly = _celly
		self.quadrant = _quadrant
		self.oppositequadrant = _oppositequadrant
		self.cellId = _cellId
		self.value = _value
		self.cellState = ECellState.UNSET
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

#region Quadrant
# quadrant complexity here comes from the fact we want to support even grids - so a cell can belong to multiple quadrants
enum EQuadrant { TOPLEFT=1<<0, TOPRIGHT=1<<1, BOTTOMLEFT=1<<2, BOTTOMRIGHT=1<<3, INVALID=0 }
class Bounds2i:
	var xmin:int
	var xmax:int
	var ymin:int
	var ymax:int
	func get_rand_vec2i_in_bounds_except(except:Vector2i) -> Vector2i:
		var x:int = randi_range(xmin, xmax)
		var y:int = randi_range(ymin, ymax)
		var safe:int = 99
		while (x==except.x && y==except.y && safe > 0):
			safe -= 1
			x = randi_range(xmin, xmax)
			y = randi_range(ymin, ymax)
		return Vector2i(x, y)

class QuadrantData:
	var xSize:int
	var ySize:int
	var leftXMax:int
	var topYMax:int
	var bottomYMin:int
	var rightXMin:int
	var lastProcessedBounds:Bounds2i
	func _init(x:int, y:int) -> void:
		xSize = x
		ySize = y
		lastProcessedBounds = Bounds2i.new()
		compute_quadrant_limits()
	func compute_quadrant_limits() -> void:
		leftXMax = int(xSize/2.0) if xSize%2 == 1 else int(xSize/2.0)-1
		rightXMin = int(xSize/2.0) if xSize%2 == 1 else int(xSize/2.0)
		topYMax = int(ySize/2.0) if ySize%2 == 1 else int(ySize/2.0)-1
		bottomYMin = int(ySize/2.0) if ySize%2 == 1 else int(ySize/2.0)
		print("quadrant setup: size %s x %s, XL=0..%s, YT=0..%s, XR=%s..%s, YB=%s..%s" % [xSize, ySize, leftXMax, topYMax, rightXMin, xSize-1, bottomYMin, ySize-1])
	func get_quadrant(x:int, y:int) -> int:
		var result:int = EQuadrant.INVALID
		if x<=leftXMax:
			if y<=topYMax: result |= EQuadrant.TOPLEFT
			if y>=bottomYMin: result |= EQuadrant.BOTTOMLEFT
		if x>=rightXMin:
			if y<=topYMax: result |= EQuadrant.TOPRIGHT
			if y>=bottomYMin: result |= EQuadrant.BOTTOMRIGHT
		assert(result != EQuadrant.INVALID, "get_quadrant fail")
		print("quadrant query for %s x %s > %s" % [x, y, result])
		return result
	func get_oppositequadrant(quadrant:int) -> int:
		var result:int = EQuadrant.INVALID
		if (quadrant & EQuadrant.TOPLEFT == EQuadrant.TOPLEFT): result |= EQuadrant.BOTTOMRIGHT
		if (quadrant & EQuadrant.BOTTOMRIGHT == EQuadrant.BOTTOMRIGHT): result |= EQuadrant.TOPLEFT
		if (quadrant & EQuadrant.TOPRIGHT == EQuadrant.TOPRIGHT): result |= EQuadrant.BOTTOMLEFT
		if (quadrant & EQuadrant.BOTTOMLEFT == EQuadrant.BOTTOMLEFT): result |= EQuadrant.TOPRIGHT
		assert(result != EQuadrant.INVALID, "get_oppositequadrant fail")
		return result
	func get_quadrant_Bounds2i(quadrant:int) -> Bounds2i:
		var xmin:int = xSize;
		var xmax:int = 0;
		var ymin:int = ySize;
		var ymax:int = 0;
		if (quadrant & EQuadrant.TOPLEFT == EQuadrant.TOPLEFT):
			xmin = min(xmin, 0)
			xmax = max(xmax, leftXMax)
			ymin = min(ymin, 0)
			ymax = max(ymax, topYMax)
			#print("quadrant TL > %s..%s %s..%s" % [xmin, xmax, ymin, ymax])
		if (quadrant & EQuadrant.TOPRIGHT == EQuadrant.TOPRIGHT):
			xmin = min(xmin, rightXMin)
			xmax = max(xmax, xSize-1)
			ymin = min(ymin, 0)
			ymax = max(ymax, topYMax)
			#print("quadrant TR > %s..%s %s..%s" % [xmin, xmax, ymin, ymax])
		if (quadrant & EQuadrant.BOTTOMLEFT == EQuadrant.BOTTOMLEFT):
			xmin = min(xmin, 0)
			xmax = max(xmax, leftXMax)
			ymin = min(ymin, bottomYMin)
			ymax = max(ymax, ySize-1)
			#print("quadrant BL > %s..%s %s..%s" % [xmin, xmax, ymin, ymax])
		if (quadrant & EQuadrant.BOTTOMRIGHT == EQuadrant.BOTTOMRIGHT):
			xmin = min(xmin, rightXMin)
			xmax = max(xmax, xSize-1)
			ymin = min(ymin, bottomYMin)
			ymax = max(ymax, ySize-1)
			#print("quadrant BR > %s..%s %s..%s" % [xmin, xmax, ymin, ymax])
		lastProcessedBounds.xmin = xmin;
		lastProcessedBounds.xmax = xmax;
		lastProcessedBounds.ymin = ymin;
		lastProcessedBounds.ymax = ymax;
		return lastProcessedBounds;
		
	#func get_quadrant_xsize(quadrant:int) -> int:
		#var xmin:int = xSize;
		#var xmax:int = 0;
		#if (quadrant & EQuadrant.TOPLEFT == EQuadrant.TOPLEFT):
			#xmin = min(xmin, 0)
			#xmax = max(xmax, leftXMax)
			#print("quadrant TL > %s..%s" % [xmin, xmax])
		#if (quadrant & EQuadrant.TOPRIGHT == EQuadrant.TOPRIGHT):
			#xmin = min(xmin, rightXMin)
			#xmax = max(xmax, xSize-1)
			#print("quadrant TR > %s..%s" % [xmin, xmax])
		#if (quadrant & EQuadrant.BOTTOMLEFT == EQuadrant.BOTTOMLEFT):
			#xmin = min(xmin, 0)
			#xmax = max(xmax, leftXMax)
			#print("quadrant BL > %s..%s" % [xmin, xmax])
		#if (quadrant & EQuadrant.BOTTOMRIGHT == EQuadrant.BOTTOMRIGHT):
			#xmin = min(xmin, rightXMin)
			#xmax = max(xmax, xSize-1)
			#print("quadrant BR > %s..%s" % [xmin, xmax])
		#return xmax - xmin + 1;
		

#endregion

var currentHoveredCell:Cell
var allCellDatas:Array[CellData] = []
var quadrantData:QuadrantData
var resetGuessAutoMode:bool = false

var quadrantHighlight:NinePatchRect

var codeLabel:CodeLabel
#var lockLabel:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quadrantHighlight = m_quadrantHighlightScene.instantiate()
	m_highlightControl.add_child(quadrantHighlight)
	Helpers.disable_and_hide_node(quadrantHighlight)
	
	codeLabel = m_codeLabelScene.instantiate()
	m_highlightControl.add_child(codeLabel)
	Helpers.disable_and_hide_node(codeLabel)
	
	#quadrantData = QuadrantData.new(5, 5)
	#var _quadrantTest:int = quadrantData.get_quadrant(0,0)
	#_quadrantTest = quadrantData.get_quadrant(4,4)
	#print("Game Ready!!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func start_new_game(xsize:int = 4, ysize:int = 4) -> void:
	print("Starting new game")
	boardXSize = xsize
	boardYSize = ysize
	quadrantData = QuadrantData.new(xsize, ysize)
	#instantiate a grid to test
	var xtopOffset:float = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset:float = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	for y:int in range(boardYSize):
		for x:int in range(boardXSize):
			var newCell:Cell = m_cellScene.instantiate()
			newCell.game = self
			newCell.global_position = Vector2(xtopOffset + x*64.0,ytopOffset + y*64.0)
			
			var code:int = randi_range(0, 9)
			var quadrant:int = quadrantData.get_quadrant(x,y)
			var oppositequadrant:int = quadrantData.get_oppositequadrant(quadrant)
			var newCellData:CellData = CellData.new(newCell, x, y, y*boardXSize+x, code, quadrant, oppositequadrant)

			allCellDatas.append(newCellData)
			#print("code value for cell %s is %s" % [(y*boardXSize+x), code])

			m_boardControl.add_child(newCell)
	#var _result:int = hackedCodes.resize(allCells.size())
	dbg_log_code()
	
	codeLabel.global_position = Vector2(xtopOffset + 64.0, ytopOffset + 64.0 * boardYSize + 64.0)


func on_cell_enter(enteredCell: Cell) -> void:
	currentHoveredCell = enteredCell
	if (resetGuessAutoMode):
		reset_guess_if_possible()
	update_quadrant_highlight()
	#print("on_cell_enter current cell: %s" % currentHoveredCell.name)


func on_cell_exit(exitedCell: Cell) -> void:
	if (exitedCell == currentHoveredCell):
		currentHoveredCell = null
	update_quadrant_highlight()
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
	elif (event.is_action_pressed("ui_guess_reset")):
			reset_guess_if_possible()
			resetGuessAutoMode = true
	elif (event.is_action_released("ui_guess_reset")):
			resetGuessAutoMode = false

func update_guess_if_possible(value:int) -> void:
	if (currentHoveredCell != null):
		var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		assert(currentHoveredCell == cellData.cellRef, "mismatch: allCellDatas[get_cell_id(cell)] != cell !!")
		var canSetGuess:bool = cellData.cellState != ECellState.SET
		if (canSetGuess):
			cellData.set_guess(value)
	
func reset_guess_if_possible() -> void:
	if (currentHoveredCell != null):
		var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		var canResetGuess:bool = cellData.cellState != ECellState.SET
		if (canResetGuess):
			cellData.reset_guess()

func get_cell_id(cell:Cell) -> int:
	for i:int in range(allCellDatas.size()):
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
	var isAlreadyHacked:bool = cellData.cellState == ECellState.SET # (cellData.codeStr != null && cellData.codeStr != "")
	if (isAlreadyHacked):
		#print("cell %d already hacked" % cellData.cellId)
		return
	generate_code_for_cell(cellData)
	cellData.cellState = ECellState.SET
	cellData.set_hacked()
	update_quadrant_highlight()

func on_cell_clicked(clickedCell:Cell) -> void:
	pass
	#if (currentHoveredCell != null):
		#var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		#var canLockLabel:bool = cellData.cellState == ECellState.SET
		#if (canLockLabel):
			#lockLabel = true
			#update_label(cellData)
		#elif (lockLabel):
			#lockLabel = false
			#update_label(null)
				
	
	#var cellData:CellData = get_cellData_from_cell(clickedCell)
	#var cellQuadrant:int = quadrantData.get_quadrant(cellData.cellx, cellData.celly)

func generate_code_for_cell(cellData:CellData) -> void:
	var targetBounds:Bounds2i = quadrantData.get_quadrant_Bounds2i(cellData.oppositequadrant)
	var path:Array[Vector2i] = []
	var cur:Vector2i = Vector2i(cellData.cellx, cellData.celly)
	var target:Vector2i = targetBounds.get_rand_vec2i_in_bounds_except(cur) # Vector2i(cellData.cellx, cellData.celly)
	var dx:int = 1 if cur.x < target.x else -1 if cur.x > target.x else 0
	var dy:int = 1 if cur.y < target.y else -1 if cur.y > target.y else 0
	#print("generate path from %s > %s, dx=%s dy=%s" % [cur, target, dx, dy])
	path.append(cur)
	var safecount:int = boardXSize + boardYSize
	while (target != cur && safecount > 0):
		safecount -= 1
		assert(dx != 0 || dy != 0, "generate_code_for_cell wrong dir?")
		var xmove:bool = (randf() <= 0.5)
		if dx == 0: xmove = false
		if dy == 0: xmove = true
		if (xmove):
			cur.x += dx
			#print("  X move to %s" % cur)
		else:
			cur.y += dy
			#print("  Y move to %s" % cur)
		path.append(cur)
		if cur.x == target.x: dx = 0
		if cur.y == target.y: dy = 0
	assert(target == cur, "generate_code_for_cell fail")
	#var dbgpath:String = "path: "
	#for pathvect in path:
		#dbgpath += "%s" % pathvect
	#print(dbgpath)
	cellData.codeStr = "" # %s" % cellData.value
	for pathvect:Vector2i in path:
		var pathcellId:int = pathvect.y*boardXSize + pathvect.x
		cellData.codeStr += "%s" % allCellDatas[pathcellId].value
		cellData.codeSequence.append(pathcellId)
	print("code: %s" % cellData.codeStr)
	

func get_quadrant_for_cell(cellData:CellData) -> int:
	return quadrantData.get_quadrant(cellData.cellx, cellData.celly)
	
func dbg_log_code() -> void:
	for y:int in range(boardYSize):
		var logstr:String = "code line %s: " % y;
		for x:int in range(boardXSize):
			var cellid:int = y*boardXSize+x
			logstr = logstr + "%s" % allCellDatas[cellid].value
		print(logstr)
	
func update_quadrant_highlight() -> void:
	if (currentHoveredCell == null):
		Helpers.disable_and_hide_node(quadrantHighlight)
		return
	var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
	if (cellData.cellState != ECellState.SET):
		Helpers.disable_and_hide_node(quadrantHighlight)
		return
	Helpers.enable_and_show_node(quadrantHighlight)
	var xtopOffset:float = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset:float = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	var bounds:Bounds2i = quadrantData.get_quadrant_Bounds2i(cellData.oppositequadrant)
	quadrantHighlight.global_position = Vector2(xtopOffset + 64.0*bounds.xmin, ytopOffset + 64.0*bounds.ymin)
	quadrantHighlight.size = Vector2(64.0*(bounds.xmax-bounds.xmin+1), 64.0*(bounds.ymax-bounds.ymin+1))
	#if (!lockLabel):
	update_label(cellData)

func update_label(cellData:CellData) -> void:
	if (cellData == null):
		Helpers.disable_and_hide_node(codeLabel)
		return;
	Helpers.enable_and_show_node(codeLabel)
	codeLabel.text = cellData.codeStr
	codeLabel.line.clear_points()
	codeLabel.line.add_point(Vector2(0, 0))
	codeLabel.line.add_point(cellData.cellRef.global_position - codeLabel.global_position + Vector2(8,64-8))
	#codeLabel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)
	
	
