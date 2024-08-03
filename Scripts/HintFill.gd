class_name HintFill
extends Object

#region other algorithm - flood fill with directional flow & filtering existing cells if not matching code

var hintCellData:CellData
var hintValues:Array[int] = []
var targetBounds:Bounds2i
var vaultGame:VaultGame
enum EFlowDir { U=1<<0, R=1<<1, L=1<<2, D=1<<3, O=1<<4 }
var processCell:Array[Vector2i] = []
var processCellDir:Array[int] = []
var processCellNew:Array[Vector2i] = []
var processCellDirNew:Array[int] = []

const vU:Vector2i = Vector2i(0, -1)
const vD:Vector2i = Vector2i(0, 1)
const vL:Vector2i = Vector2i(-1, 0)
const vR:Vector2i = Vector2i(1, 0)

var pushHintCurrentValue:int
var stepsLeft:int

func _init(game:VaultGame) -> void:
	vaultGame = game

func update_hint() -> void:
	if ( hintValues.size() == 0 ): return
	
	processCellDirNew.clear()
	processCellNew.clear()
	pushHintCurrentValue = hintValues.pop_front()
	stepsLeft = hintValues.size()
	for i:int in range(processCellDir.size()):
		var pos:Vector2i = processCell[i]
		if (processCellDir[i] & EFlowDir.O == EFlowDir.O):
			push_from_origin(pos) # special cases based on starting quadrant
		else:
			var pushedDir:int = processCellDir[i]
			if (processCellDir[i] & EFlowDir.L == EFlowDir.L):
				# writing pushedDir &=... trigger a warning about pushedDir not being used if pushedDir is moved to local block?
				pushedDir &= (EFlowDir.D | EFlowDir.L | EFlowDir.U) # remove R if it was in the original
				push(pos + vL, pushedDir)
			if (processCellDir[i] & EFlowDir.U == EFlowDir.U):
				pushedDir &= (EFlowDir.L | EFlowDir.U | EFlowDir.R) # remove D if it was in the original
				push(pos + vU, pushedDir)
			if (processCellDir[i] & EFlowDir.R == EFlowDir.R):
				pushedDir  &= (EFlowDir.U | EFlowDir.R | EFlowDir.D) # remove L if it was in the original
				push(pos + vR, pushedDir)
			if (processCellDir[i] & EFlowDir.D == EFlowDir.D):
				pushedDir &= (EFlowDir.R | EFlowDir.D | EFlowDir.L) # remove U if it was in the original
				push(pos + vD, pushedDir)
	vaultGame.update_hints_for_cells(processCellNew, pushHintCurrentValue)
	processCellDir = processCellDirNew.duplicate();
	processCell = processCellNew.duplicate();

func start_hint(startCellData:CellData) -> void:
	if (hintCellData == startCellData):
		clear()
		#update_hint()
		return
		
	hintCellData = startCellData
	targetBounds = vaultGame.quadrantData.get_quadrant_Bounds2i(hintCellData.oppositequadrant)
	processCell.clear()
	processCellDir.clear()
	processCell.append(Vector2i(startCellData.cellx, startCellData.celly))
	processCellDir.append(EFlowDir.O)
	process_codestr_to_hintValues(hintCellData.codeStr)

func clear() -> void:
	hintCellData = null;
	vaultGame.clear_all_hints()

func process_codestr_to_hintValues(codestr:String) -> void:
	hintValues.clear()
	for digitchar:String in codestr:
		if digitchar.is_valid_int():
			hintValues.push_back(digitchar.to_int())
	var _removed:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit

func push(pos:Vector2i, dir:int) -> void:
	if ( !vaultGame.is_valid_pos(pos)): return
	if ( targetBounds.distance_to_pos(pos) > stepsLeft): return;
	var cellid:int = pos.y*vaultGame.boardXSize+pos.x
	var cellData:CellData = vaultGame.allCellDatas[cellid]
	if (cellData.cellState == CellData.ECellState.SET && cellData.value != pushHintCurrentValue): return
	if (cellData.cellState == CellData.ECellState.GUESS && cellData.guess != pushHintCurrentValue): return
	var posId:int = processCellNew.find(pos)
	if (posId >= 0):
		processCellDirNew[posId] |= dir
	else:
		processCellDirNew.append(dir)
		processCellNew.append(pos)

func push_from_origin(pos:Vector2i) -> void:
	# initialize the cellular automata, special cases to handle based on the starting quadrant
	var quadrant:int = hintCellData.quadrant
	var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	if (isTL && isTR && isBL && isBR): # center, need to flow in all directions
		push(pos + vU, EFlowDir.L | EFlowDir.U | EFlowDir.R)
		push(pos + vR, EFlowDir.U | EFlowDir.R | EFlowDir.D)
		push(pos + vD, EFlowDir.R | EFlowDir.D | EFlowDir.L)
		push(pos + vL, EFlowDir.D | EFlowDir.L | EFlowDir.U)
	elif (isTL && isTR): # center top, need to flow everywhere except up
		push(pos + vR, EFlowDir.R | EFlowDir.D)
		push(pos + vD, EFlowDir.R | EFlowDir.D | EFlowDir.L)
		push(pos + vL, EFlowDir.D | EFlowDir.L)
	elif (isTR && isBR): # center right, need to spread everywhere except right
		push(pos + vU, EFlowDir.L | EFlowDir.U)
		push(pos + vD, EFlowDir.D | EFlowDir.L)
		push(pos + vL, EFlowDir.D | EFlowDir.L | EFlowDir.U)
	elif (isBR && isBL): # center bottom, need to spread everywhere except down
		push(pos + vU, EFlowDir.L | EFlowDir.U | EFlowDir.R)
		push(pos + vR, EFlowDir.U | EFlowDir.R)
		push(pos + vL, EFlowDir.L | EFlowDir.U)
	elif (isBL && isTL): # center left, need to spread everywhere except left
		push(pos + vU, EFlowDir.U | EFlowDir.R)
		push(pos + vR, EFlowDir.U | EFlowDir.R | EFlowDir.D)
		push(pos + vD, EFlowDir.R | EFlowDir.D)
	elif (isTL): # spread DR only
		push(pos + vR, EFlowDir.R | EFlowDir.D)
		push(pos + vD, EFlowDir.R | EFlowDir.D)
	elif (isTR): # spread DL only
		push(pos + vD, EFlowDir.D | EFlowDir.L)
		push(pos + vL, EFlowDir.D | EFlowDir.L)
	elif (isBL): # spread UR only
		push(pos + vU, EFlowDir.U | EFlowDir.R)
		push(pos + vR, EFlowDir.U | EFlowDir.R)
	elif (isBR): # spread UL only
		push(pos + vU, EFlowDir.L | EFlowDir.U)
		push(pos + vL, EFlowDir.L | EFlowDir.U)
	else:
		assert(false, "push_from_origin fail, no quadrant?")

#endregion

##region old algorithm - working fine except complex to filter path from already existing hacked/guess cells
#var hintCellData:CellData
#var hintValues:Array[int] = []
#enum EProcessDir { UR, RD, DL, LU, U, R, D, L, O }
#var processCell:Array[Vector2i] = []
#var processCellDir:Array[EProcessDir] = []
#var processCellNew:Array[Vector2i] = []
#var processCellDirNew:Array[EProcessDir] = []
#
#var vaultGame:VaultGame
#
#const vU:Vector2i = Vector2i(0, -1)
#const vD:Vector2i = Vector2i(0, 1)
#const vL:Vector2i = Vector2i(-1, 0)
#const vR:Vector2i = Vector2i(1, 0)
#
#func _init(game:VaultGame) -> void:
	#vaultGame = game
	#
#func start_hint(startCellData:CellData) -> void:
	#if (hintCellData == startCellData):
		#clear()
		#return
		#
	#hintCellData = startCellData
	#processCell.clear()
	#processCellDir.clear()
	#processCell.append(Vector2i(startCellData.cellx, startCellData.celly))
	#processCellDir.append(EProcessDir.O)
	#process_codestr_to_hintValues(hintCellData.codeStr)
#
#
#func process_codestr_to_hintValues(codestr:String) -> void:
	#hintValues.clear()
	#for digitchar:String in codestr:
		#if digitchar.is_valid_int():
			#hintValues.push_back(digitchar.to_int())
	#var _removed:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit
#
#func pushUR(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.UR)
		#processCellNew.append(pos)
#func pushRD(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.RD)
		#processCellNew.append(pos)
#func pushDL(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.DL)
		#processCellNew.append(pos)
#func pushLU(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.LU)
		#processCellNew.append(pos)
#func pushU(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.U)
		#processCellNew.append(pos)
#func pushR(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.R)
		#processCellNew.append(pos)
#func pushD(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.D)
		#processCellNew.append(pos)
#func pushL(pos:Vector2i) -> void:
		#processCellDirNew.append(EProcessDir.L)
		#processCellNew.append(pos)
#
#func update_hint() -> void:
	#if ( hintValues.size() == 0 ): return
	#
	#processCellDirNew.clear()
	#processCellNew.clear()
	#for i:int in range(processCellDir.size()):
		#var pos:Vector2i = processCell[i]
		#if (vaultGame.is_valid_pos(pos)):
			#match processCellDir[i]:
				#EProcessDir.O:
					#push_from_origin(pos) # special cases based on starting quadrant
				#EProcessDir.UR:
					#pushU(pos + vU)
					#pushUR(pos + vR)
				#EProcessDir.RD:
					#pushR(pos + vR)
					#pushRD(pos + vD)
				#EProcessDir.DL:
					#pushD(pos + vD)
					#pushDL(pos + vL)
				#EProcessDir.LU:
					#pushL(pos + vL)
					#pushLU(pos + vU)
				#EProcessDir.U:
					#pushU(pos + vU)
				#EProcessDir.R:
					#pushR(pos + vR)
				#EProcessDir.D:
					#pushD(pos + vD)
				#EProcessDir.L:
					#pushL(pos + vL)
	#var hintValue:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit
	#vaultGame.update_hints_for_cells(processCellNew, hintValue)
	#processCellDir = processCellDirNew.duplicate();
	#processCell = processCellNew.duplicate();
	#
#func clear() -> void:
	#hintCellData = null;
	#vaultGame.clear_all_hints()
#
#func push_from_origin(pos:Vector2i) -> void:
	## initialize the cellular automata, special cases to handle based on the starting quadrant
	#var quadrant:int = hintCellData.quadrant
	#var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	#var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	#var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	#var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	#if (isTL && isTR && isBL && isBR): # center, need to spread in all directions
		#pushUR(pos + vU)
		#pushRD(pos + vR)
		#pushDL(pos + vD)
		#pushLU(pos + vL)
	#elif (isTL && isTR): # center top, need to spread everywhere except up
		#pushRD(pos + vR)
		#pushDL(pos + vD)
		#pushL(pos + vL)
	#elif (isTR && isBR): # center right, need to spread everywhere except right
		#pushDL(pos + vD)
		#pushLU(pos + vL)
		#pushU(pos + vU)
	#elif (isBR && isBL): # center bottom, need to spread everywhere except down
		#pushLU(pos + vL)
		#pushUR(pos + vU)
		#pushR(pos + vR)
	#elif (isBL && isTL): # center left, need to spread everywhere except left
		#pushUR(pos + vU)
		#pushRD(pos + vR)
		#pushD(pos + vD)
	#elif (isTL): # spread DR only
		#pushRD(pos + vR)
		#pushD(pos + vD)
	#elif (isTR): # spread DL only
		#pushDL(pos + vD)
		#pushL(pos + vL)
	#elif (isBL): # spread UR only
		#pushUR(pos + vU)
		#pushR(pos + vR)
	#elif (isBR): # spread UL only
		#pushLU(pos + vL)
		#pushU(pos + vU)
	#else:
		#assert(false, "push_from_origin fail, no quadrant?")
		#
#
#
## using Cellular automata to fill around the origin with no overlap to check & single step/distance each iteration:
## O pushes UR up, RD right, DL down, LU left (for all directions, see specific setup if some directions are under constraint)
## UR pushes U up, UR right
## RD pushes R right, RD down
## DL pushes D down, DL left
## LU pushes L left, LU up
## U/R/D/L pushes U/R/D/L up/right/down/left respectively (stay in their direction)
#
## for the cell grid, U is y-1, R is x+1, D is Y+1, L is x-1
## /!\ only works with 2D grids
#
#endregion
