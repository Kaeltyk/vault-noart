class_name VaultGame
extends CanvasLayer

@export var m_initializer:Initializer
@export var m_cellScene:PackedScene
@export var m_quadrantHighlightScene:PackedScene
@export var m_codeLabelScene:PackedScene
@export var m_boardControl:Control
@export var m_highlightControl:Control
@export var m_menuButton:Button
@export var m_unlockButton:Button
@export var m_resultControl:ResultControl

var boardXSize:int = 3
var boardYSize:int = 7

var currentHoveredCell:Cell
var allCellDatas:Array[CellData] = []
var quadrantData:QuadrantData
var resetGuessAutoMode:bool = false

var quadrantHighlight:NinePatchRect

var hintFill:HintFill

enum ELabelPos { TOP, BOTTOM }
var codeLabel:CodeLabel
var hoverCodeLabel:CodeLabel
var codeLabelHeight:float

var boardResolved:bool = false
var isBoardDirtyForHints:bool = false
#var lockLabel:bool = false

func _enter_tree() -> void:
	SaveManager.load_resource()
	print("Game _enter_tree %s" %Helpers.get_frame_string(self))
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quadrantHighlight = m_quadrantHighlightScene.instantiate()
	m_highlightControl.add_child(quadrantHighlight)
	Helpers.disable_and_hide_node(quadrantHighlight)
	
	codeLabel = m_codeLabelScene.instantiate()
	m_highlightControl.add_child(codeLabel)
	Helpers.disable_and_hide_node(codeLabel)
	codeLabelHeight = codeLabel.size.y
	
	hoverCodeLabel = m_codeLabelScene.instantiate()
	m_highlightControl.add_child(hoverCodeLabel)
	Helpers.disable_and_hide_node(hoverCodeLabel)
	

	m_resultControl.setup(self)

	var _result:int = m_menuButton.pressed.connect(_on_menuButton_pressed)
	_result = m_unlockButton.pressed.connect(_on_openlockButton_pressed)
	
	hintFill = HintFill.new(self)

	#var arraytest:Array[int] = [1,2,22,12,9,7,6,4]
	#if 12 in arraytest: print("12 is in!")
	#var pos:int = arraytest.find(9)
	#print("found 9 at pos %s" %pos)
	
	#quadrantData = QuadrantData.new(5, 5)
	#var _quadrantTest:int = quadrantData.get_quadrant(0,0)
	#_quadrantTest = quadrantData.get_quadrant(4,4)
	#print("Game Ready!!")

func _on_menuButton_pressed() -> void:
	#Helpers.toggle_show_hide_node(m_initializer.m_menuCanvas)
	if (m_initializer.m_menuCanvas.process_mode == Node.PROCESS_MODE_DISABLED):
		Helpers.enable_and_show_node(m_initializer.m_menuCanvas)
	else:
		m_initializer.m_menuCanvas.close_menu()
		m_menuButton.release_focus()

func _on_openlockButton_pressed() -> void:
	if ( !boardResolved ):
		resolve_board()

func resolve_board() -> void:
	boardResolved = true
	currentHoveredCell = null
	clear_all_hints()
	update_quadrant_highlight()
	update_hover_label(null)
	update_perma_label(null)
	var success:bool = true
	var hackCount:int = 0
	var cellCount:int = boardXSize * boardYSize
	for cellData:CellData in allCellDatas:
		cellData.cellRef.lock_button()
		if cellData.cellState == CellData.ECellState.UNSET:
			cellData.cellRef.display_error(cellData.value)
			success = false
		elif cellData.cellState == CellData.ECellState.GUESS:
			if (cellData.guess != cellData.value):
				cellData.cellRef.display_error(cellData.value)
				success = false
			else:
				cellData.cellRef.display_success(cellData.value)
		elif cellData.cellState == CellData.ECellState.SET:
			hackCount += 1
	var score:float = (1.0 - hackCount / float(cellCount)) if success else 0.0
	update_save(success, score)
	m_resultControl.open_result(success, score)

func update_save(isSuccess:bool, score:float) -> void:
	var sizeId:int = boardXSize - 3 # hack, would require a cleaner process, maybe a SaveManager return function
	SaveManager.saveData.gamesCount[sizeId] += 1
	if ( isSuccess ):
		var oldGameCount:int = SaveManager.saveData.gamessuccessCount[sizeId]
		var oldAverageScore:float = SaveManager.saveData.gamesScoreAvg[sizeId]
		var newAverageScore:float = (oldAverageScore * oldGameCount + score)/float(oldGameCount+1)
		SaveManager.saveData.gamessuccessCount[sizeId] += 1
		SaveManager.saveData.gamesScoreAvg[sizeId] = newAverageScore
	SaveManager.save_resource()

func clear_old_game() -> void:
	if (allCellDatas.size() > 0):
		for cellData:CellData in allCellDatas:
			Helpers.disable_and_hide_node(cellData.cellRef);
			cellData.cellRef.queue_free()
	currentHoveredCell = null
	allCellDatas.clear();
	resetGuessAutoMode = false;
	Helpers.disable_and_hide_node(quadrantHighlight)
	Helpers.disable_and_hide_node(codeLabel)
	Helpers.disable_and_hide_node(hoverCodeLabel)
	boardResolved = false
	hintFill.clear()
	m_resultControl.close_result()

func new_game_same_size() -> void:
	start_new_game(boardXSize, boardYSize)

func start_new_game(xsize:int = 4, ysize:int = 4) -> void:
	print("Starting new game")
	clear_old_game()
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
	
	# update code labels pos according to (dynamic) board size
	codeLabel.global_position = Vector2(xtopOffset + 64.0, ytopOffset + 64.0 * boardYSize + 64.0)
	hoverCodeLabel.global_position = Vector2(xtopOffset + 64.0, ytopOffset - 64.0 - 64.0)


func on_cell_enter(enteredCell: Cell) -> void:
	currentHoveredCell = enteredCell
	if (resetGuessAutoMode):
		reset_guess_if_possible()
	update_quadrant_highlight()
	var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
	if ( cellData.cellState == CellData.ECellState.SET ):
		update_hover_label(cellData)
	#print("on_cell_enter current cell: %s" % currentHoveredCell.name)


func on_cell_exit(exitedCell: Cell) -> void:
	if (exitedCell == currentHoveredCell):
		currentHoveredCell = null
	update_quadrant_highlight()
	update_hover_label(null)
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
		var canSetGuess:bool = cellData.cellState != CellData.ECellState.SET
		if (canSetGuess):
			cellData.set_guess(value)
			isBoardDirtyForHints = true
	
func reset_guess_if_possible() -> void:
	if (currentHoveredCell != null):
		var cellData:CellData = get_cellData_from_cell(currentHoveredCell)
		var canResetGuess:bool = cellData.cellState != CellData.ECellState.SET
		if (canResetGuess):
			cellData.reset_guess()
			isBoardDirtyForHints = true

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
	var isAlreadyHacked:bool = cellData.cellState == CellData.ECellState.SET # (cellData.codeStr != null && cellData.codeStr != "")
	if (isAlreadyHacked):
		#print("cell %d already hacked" % cellData.cellId)
		return
	isBoardDirtyForHints = true
	generate_code_for_cell(cellData)
	cellData.cellState = CellData.ECellState.SET
	cellData.set_hacked()
	update_quadrant_highlight()
	update_hover_label(cellData)

func on_cell_clicked(clickedCell:Cell) -> void:
	var cellData:CellData = get_cellData_from_cell(clickedCell)
	if (cellData.cellState == CellData.ECellState.SET):
		clear_all_hints()
		if (hintFill.hintCellData == cellData):
			hintFill.clear()
			update_perma_label(null)
		else:
			hintFill.clear()
			hintFill.start_hint(cellData)
			update_perma_label(cellData)

func generate_code_for_cell(cellData:CellData) -> void:
	var targetBounds:Bounds2i = quadrantData.get_quadrant_Bounds2i(cellData.oppositequadrant)
	var path:Array[Vector2i] = []
	var cur:Vector2i = cellData.pos
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
	#print("code: %s" % cellData.codeStr)
	

func get_quadrant_for_cell(cellData:CellData) -> int:
	return quadrantData.get_quadrant(cellData.pos.x, cellData.pos.y)
	
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
	if (cellData.cellState != CellData.ECellState.SET):
		Helpers.disable_and_hide_node(quadrantHighlight)
		return
	Helpers.enable_and_show_node(quadrantHighlight)
	var xtopOffset:float = 1920/2.0 - 64.0 * (boardXSize/2.0 + 0.5)
	var ytopOffset:float = 1080/2.0 - 64.0 * (boardYSize/2.0 + 0.5)
	var bounds:Bounds2i = quadrantData.get_quadrant_Bounds2i(cellData.oppositequadrant)
	quadrantHighlight.global_position = Vector2(xtopOffset + 64.0*bounds.xmin, ytopOffset + 64.0*bounds.ymin)
	quadrantHighlight.size = Vector2(64.0*(bounds.xmax-bounds.xmin+1), 64.0*(bounds.ymax-bounds.ymin+1))

func update_hover_label(cellData:CellData) -> void:
	update_label(cellData, hoverCodeLabel, ELabelPos.BOTTOM)
func update_perma_label(cellData:CellData) -> void:
	update_label(cellData, codeLabel, ELabelPos.TOP)
	
func update_label(cellData:CellData, updatedCodeLabel:CodeLabel, labelPos:ELabelPos) -> void:
	if (cellData == null):
		Helpers.disable_and_hide_node(updatedCodeLabel)
		return;
	Helpers.enable_and_show_node(updatedCodeLabel)
	updatedCodeLabel.text = cellData.codeStr
	updatedCodeLabel.line.clear_points()
	match labelPos:
		ELabelPos.BOTTOM:
			updatedCodeLabel.line.add_point(Vector2(0, codeLabelHeight))
			updatedCodeLabel.line.add_point(cellData.cellRef.global_position - updatedCodeLabel.global_position + Vector2(8,8))
		ELabelPos.TOP:
			updatedCodeLabel.line.add_point(Vector2(0, 0))
			updatedCodeLabel.line.add_point(cellData.cellRef.global_position - updatedCodeLabel.global_position + Vector2(8,64-8))
	#codeLabel.set_anchors_preset(Control.PRESET_TOP_LEFT, true)

func clear_all_hints() -> void:
	for cellData:CellData in allCellDatas:
		cellData.cellRef.hide_hint_label()
		cellData.cellRef.hide_flow()

func update_hints_for_cells(cellsPos:Array[Vector2i], hintvalue:int) -> void:
	for pos:Vector2i in cellsPos:
		var cellid:int = pos.y*boardXSize+pos.x
		var cellData:CellData = allCellDatas[cellid]
		if ( cellData.cellState == CellData.ECellState.UNSET):
			allCellDatas[cellid].cellRef.display_hint_label(hintvalue)

func is_valid_pos(pos:Vector2i) -> bool:
	return (pos.x >= 0 && pos.x < boardXSize && pos.y >= 0 && pos.y < boardYSize)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	hintFill.update_hint()
	check_hints_validation()

func check_hints_validation() -> void:
	if ( !isBoardDirtyForHints ): return
	for cellData:CellData in allCellDatas:
		if (cellData.cellState == CellData.ECellState.SET):
			check_validation_for_cell(cellData)
	isBoardDirtyForHints = false

func check_validation_for_cell(cellData:CellData) -> void:
	var pathResult:HintFill.EPathResult = hintFill.check_path(cellData)
	if ( pathResult == HintFill.EPathResult.SUCCESS ):
		cellData.cellRef.display_as_valid(true)
	elif ( pathResult == HintFill.EPathResult.INVALID ):
		cellData.cellRef.display_as_valid(false)
	else:
		cellData.cellRef.hide_validation()
