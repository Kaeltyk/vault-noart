class_name HintFill
extends Object

var hintCellData:CellData
var hintValues:Array[int] = []
enum EProcessDir { UR, RD, DL, LU, U, R, D, L, O }
var processCell:Array[Vector2i] = []
var processCellDir:Array[EProcessDir] = []
var processCellNew:Array[Vector2i] = []
var processCellDirNew:Array[EProcessDir] = []

var vaultGame:VaultGame

func _init(game:VaultGame) -> void:
	vaultGame = game
	
func start_hint(startCellData:CellData) -> void:
	hintCellData = startCellData
	processCell.clear()
	processCellDir.clear()
	processCell.append(Vector2i(startCellData.cellx, startCellData.celly))
	processCellDir.append(EProcessDir.O)
	process_codestr_to_hintValues(hintCellData.codeStr)

func process_codestr_to_hintValues(str:String) -> void:
	hintValues.clear()
	for digitchar in str:
		if digitchar.is_valid_int():
			hintValues.push_back(digitchar.to_int())
	var _removed:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit

func update_hint() -> void:
	if ( hintValues.size() == 0 ): return
	
	processCellDirNew.clear()
	processCellNew.clear()
	for i:int in range(processCellDir.size()):
		var pos:Vector2i = processCell[i]
		if (vaultGame.is_valid_pos(pos)):
			match processCellDir[i]:
				EProcessDir.O:
					processCellDirNew.append(EProcessDir.UR)
					processCellNew.append(pos + Vector2i(-1,0))
					processCellDirNew.append(EProcessDir.RD)
					processCellNew.append(pos + Vector2i(0,1))
					processCellDirNew.append(EProcessDir.DL)
					processCellNew.append(pos + Vector2i(1,0))
					processCellDirNew.append(EProcessDir.LU)
					processCellNew.append(pos + Vector2i(0,-1))
				EProcessDir.UR:
					processCellDirNew.append(EProcessDir.U)
					processCellNew.append(pos + Vector2i(-1,0))
					processCellDirNew.append(EProcessDir.UR)
					processCellNew.append(pos + Vector2i(0,1))
				EProcessDir.RD:
					processCellDirNew.append(EProcessDir.R)
					processCellNew.append(pos + Vector2i(0,1))
					processCellDirNew.append(EProcessDir.RD)
					processCellNew.append(pos + Vector2i(1,0))
				EProcessDir.DL:
					processCellDirNew.append(EProcessDir.D)
					processCellNew.append(pos + Vector2i(1,0))
					processCellDirNew.append(EProcessDir.DL)
					processCellNew.append(pos + Vector2i(0,-1))
				EProcessDir.LU:
					processCellDirNew.append(EProcessDir.L)
					processCellNew.append(pos + Vector2i(0,-1))
					processCellDirNew.append(EProcessDir.LU)
					processCellNew.append(pos + Vector2i(-1,0))
				EProcessDir.U:
					processCellDirNew.append(EProcessDir.U)
					processCellNew.append(pos + Vector2i(-1,0))
				EProcessDir.R:
					processCellDirNew.append(EProcessDir.R)
					processCellNew.append(pos + Vector2i(0,1))
				EProcessDir.D:
					processCellDirNew.append(EProcessDir.D)
					processCellNew.append(pos + Vector2i(1,0))
				EProcessDir.L:
					processCellDirNew.append(EProcessDir.L)
					processCellNew.append(pos + Vector2i(0,-1))
	var hintValue:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit
	vaultGame.update_hints_for_cells(processCellNew, hintValue)
	processCellDir = processCellDirNew.duplicate();
	processCell = processCellNew.duplicate();
	
func clear() -> void:
	pass

# Kind of Cellular automata to fill around the origin with no overlap & single step/distance each time:
# O pushes UR up, RD right, DL down, LU left
# UR pushes U up, UR right
# RD pushes R right, RD down
# DL pushes D down, DL left
# LU pushes L left, LU up
# U/R/D/L pushes U/R/D/L up/right/down/left respectively (stay in their direction)

# /!\ only works with 2D grids
