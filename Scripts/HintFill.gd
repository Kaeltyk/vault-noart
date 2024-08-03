class_name HintFill
extends Object

var hintCellData:CellData
var hintValues:Array[int] = []
enum EProcessDir { UR, RD, DL, LU, U, R, D, L, O }
var processCell:Array[Vector2i] = []
var processCellDir:Array[EProcessDir] = []
var processCellNew:Array[Vector2i] = []
var processCellDirNew:Array[EProcessDir] = []
#var forbiddenDirs:Array[EProcessDir] = []

var vaultGame:VaultGame

const vU:Vector2i = Vector2i(0, -1)
const vD:Vector2i = Vector2i(0, 1)
const vL:Vector2i = Vector2i(-1, 0)
const vR:Vector2i = Vector2i(1, 0)

func _init(game:VaultGame) -> void:
	vaultGame = game
	
func start_hint(startCellData:CellData) -> void:
	if (hintCellData == startCellData):
		clear()
		return
		
	hintCellData = startCellData
	processCell.clear()
	processCellDir.clear()
	processCell.append(Vector2i(startCellData.cellx, startCellData.celly))
	processCellDir.append(EProcessDir.O)
	process_codestr_to_hintValues(hintCellData.codeStr)
	#init_forbidden_dirs()
	#print("forbidden dirs:")
	#for dir:EProcessDir in forbiddenDirs:
		#print("    %s" % dir)


func process_codestr_to_hintValues(codestr:String) -> void:
	hintValues.clear()
	for digitchar:String in codestr:
		if digitchar.is_valid_int():
			hintValues.push_back(digitchar.to_int())
	var _removed:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit

func pushUR(pos:Vector2i) -> void:
	#if ( !(EProcessDir.U in forbiddenDirs || EProcessDir.R in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.UR)
		processCellNew.append(pos)
func pushRD(pos:Vector2i) -> void:
	#if ( !(EProcessDir.R in forbiddenDirs || EProcessDir.D in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.RD)
		processCellNew.append(pos)
func pushDL(pos:Vector2i) -> void:
	#if ( !(EProcessDir.D in forbiddenDirs || EProcessDir.L in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.DL)
		processCellNew.append(pos)
func pushLU(pos:Vector2i) -> void:
	#if ( !(EProcessDir.L in forbiddenDirs || EProcessDir.U in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.LU)
		processCellNew.append(pos)
func pushU(pos:Vector2i) -> void:
	#if ( !(EProcessDir.U in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.U)
		processCellNew.append(pos)
func pushR(pos:Vector2i) -> void:
	#if ( !(EProcessDir.R in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.R)
		processCellNew.append(pos)
func pushD(pos:Vector2i) -> void:
	#if ( !(EProcessDir.D in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.D)
		processCellNew.append(pos)
func pushL(pos:Vector2i) -> void:
	#if ( !(EProcessDir.L in forbiddenDirs) ):
		processCellDirNew.append(EProcessDir.L)
		processCellNew.append(pos)

func update_hint() -> void:
	if ( hintValues.size() == 0 ): return
	
	processCellDirNew.clear()
	processCellNew.clear()
	for i:int in range(processCellDir.size()):
		var pos:Vector2i = processCell[i]
		if (vaultGame.is_valid_pos(pos)):
			match processCellDir[i]:
				EProcessDir.O:
					push_from_origin(pos) # special cases based on starting quadrant
				EProcessDir.UR:
					pushU(pos + vU)
					pushUR(pos + vR)
				EProcessDir.RD:
					pushR(pos + vR)
					pushRD(pos + vD)
				EProcessDir.DL:
					pushD(pos + vD)
					pushDL(pos + vL)
				EProcessDir.LU:
					pushL(pos + vL)
					pushLU(pos + vU)
				EProcessDir.U:
					pushU(pos + vU)
				EProcessDir.R:
					pushR(pos + vR)
				EProcessDir.D:
					pushD(pos + vD)
				EProcessDir.L:
					pushL(pos + vL)
	var hintValue:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit
	vaultGame.update_hints_for_cells(processCellNew, hintValue)
	processCellDir = processCellDirNew.duplicate();
	processCell = processCellNew.duplicate();
	
func clear() -> void:
	hintCellData = null;
	vaultGame.clear_all_hints()

#func init_forbidden_dirs() -> void:
	#forbiddenDirs.clear()
	#var quadrant:int = hintCellData.quadrant
	#var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	#var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	#var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	#var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	#if (isTL && isTR && isBL && isBR):
		#return # center cell, no direction forbidden
	#if (isTL && isTR):
		#forbiddenDirs.append(EProcessDir.U)
		#return
	#if (isTR && isBR):
		#forbiddenDirs.append(EProcessDir.R)
		#return
	#if (isBR && isBL):
		#forbiddenDirs.append(EProcessDir.D)
		#return
	#if (isBL && isTL):
		#forbiddenDirs.append(EProcessDir.L)
		#return
	#if (isTL):
		#forbiddenDirs.append(EProcessDir.U)
		#forbiddenDirs.append(EProcessDir.L)
		#return;
	#if (isTR):
		#forbiddenDirs.append(EProcessDir.U)
		#forbiddenDirs.append(EProcessDir.R)
		#return;
	#if (isBR):
		#forbiddenDirs.append(EProcessDir.D)
		#forbiddenDirs.append(EProcessDir.R)
		#return;
	#if (isBL):
		#forbiddenDirs.append(EProcessDir.D)
		#forbiddenDirs.append(EProcessDir.L)
		#return;

func push_from_origin(pos:Vector2i) -> void:
	# initialize the cellular automata, special cases to handle based on the starting quadrant
	var quadrant:int = hintCellData.quadrant
	var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	if (isTL && isTR && isBL && isBR): # center, need to spread in all directions
		pushUR(pos + vU)
		pushRD(pos + vR)
		pushDL(pos + vD)
		pushLU(pos + vL)
	elif (isTL && isTR): # center top, need to spread everywhere except up
		pushRD(pos + vR)
		pushDL(pos + vD)
		pushL(pos + vL)
	elif (isTR && isBR): # center right, need to spread everywhere except right
		pushDL(pos + vD)
		pushLU(pos + vL)
		pushU(pos + vU)
	elif (isBR && isBL): # center bottom, need to spread everywhere except down
		pushLU(pos + vL)
		pushUR(pos + vU)
		pushR(pos + vR)
	elif (isBL && isTL): # center left, need to spread everywhere except left
		pushUR(pos + vU)
		pushRD(pos + vR)
		pushD(pos + vD)
	elif (isTL): # spread DR only
		pushRD(pos + vR)
		pushD(pos + vD)
	elif (isTR): # spread DL only
		pushDL(pos + vD)
		pushL(pos + vL)
	elif (isBL): # spread UR only
		pushUR(pos + vU)
		pushR(pos + vR)
	elif (isBR): # spread UL only
		pushLU(pos + vL)
		pushU(pos + vU)
	else:
		assert(false, "push_from_origin fail, no quadrant?")
		


# using Cellular automata to fill around the origin with no overlap to check & single step/distance each iteration:
# O pushes UR up, RD right, DL down, LU left
# UR pushes U up, UR right
# RD pushes R right, RD down
# DL pushes D down, DL left
# LU pushes L left, LU up
# U/R/D/L pushes U/R/D/L up/right/down/left respectively (stay in their direction)

# for the cell grid, U is y-1, R is x+1, D is Y+1, L is x-1
# /!\ only works with 2D grids
