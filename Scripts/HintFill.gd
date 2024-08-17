class_name HintFill
extends Object

#region - flood fill with directional flow & filtering existing cells if not matching code

enum EPathResult { NONE, SUCCESS, INVALID }
enum EFlowDir { U=1<<0, R=1<<1, L=1<<2, D=1<<3, O=1<<4 }
const vU:Vector2i = Vector2i(0, -1)
const vD:Vector2i = Vector2i(0, 1)
const vL:Vector2i = Vector2i(-1, 0)
const vR:Vector2i = Vector2i(1, 0)
const vDirs:Array[Vector2i] = [vU, vD, vL, vR]

var hintCellData:CellData
var hintValues:Array[int] = []
var targetBounds:Bounds2i
var vaultGame:VaultGame

var DBG_flowCheck:bool = false
var DBG_pathCheck:bool = false

class FlowCell:
	var pos:Vector2i
	var fromDir:int
	var outFlowDir:int
	var possibleFlowDir:int
	var needFlow:bool = false 	# update flow, should be done once
	var isDirty: bool = false		# plan for next update, for reverse flow
	var hintValue:int
	func _init(_pos:Vector2i, _fromDir:int, _hintValue:int) -> void:
		pos = _pos
		fromDir = _fromDir
		outFlowDir = 0
		needFlow = true
		hintValue = _hintValue
	func set_out_flow_dir(_outFlowDir:int) -> void:
		assert(outFlowDir == 0, "FlowCell:set_out_flow_dir should only be set once")
		outFlowDir = _outFlowDir
		possibleFlowDir = _outFlowDir

var allFlowCells:Array[FlowCell] = []
var newFlowCells:Array[FlowCell] = []

var pushHintCurrentValue:int
var stepsLeft:int
var hintUpdateFinished:bool = true

func _init(game:VaultGame) -> void:
	vaultGame = game

func start_hint(startCellData:CellData) -> void:
	hintCellData = startCellData
	targetBounds = vaultGame.quadrantData.get_quadrant_Bounds2i(hintCellData.oppositequadrant)
	allFlowCells.clear()
	hintValues = process_codestr_to_hintValues(hintCellData.codeStr)
	pushHintCurrentValue = hintValues.pop_front()
	setup_startFlowCell();
	hintUpdateFinished = false

func get_flow_cell_at_pos(pos:Vector2i) -> FlowCell:
	for flowCell:FlowCell in allFlowCells:
		if (flowCell.pos == pos):
			return flowCell
	for flowCell:FlowCell in newFlowCells:
		if (flowCell.pos == pos):
			return flowCell
	return null
	
func setup_startFlowCell() -> void:
	var startFlowCell:FlowCell = FlowCell.new(hintCellData.pos, EFlowDir.O, pushHintCurrentValue)
	startFlowCell.set_out_flow_dir(get_quadrant_flow_dir(hintCellData))
	allFlowCells.append(startFlowCell)

func get_quadrant_flow_dir(cellData:CellData) -> int:
	var quadrant:int = cellData.quadrant
	var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	if (isTL && isTR && isBL && isBR): # center, need to flow in all directions
		return EFlowDir.L | EFlowDir.U | EFlowDir.R | EFlowDir.D
	elif (isTL && isTR): # center top, need to flow everywhere except up
		return EFlowDir.L | EFlowDir.R | EFlowDir.D
	elif (isTR && isBR): # center right, need to flow everywhere except right
		return EFlowDir.L | EFlowDir.U | EFlowDir.D
	elif (isBR && isBL): # center bottom, need to flow everywhere except down
		return EFlowDir.L | EFlowDir.U | EFlowDir.R
	elif (isBL && isTL): # center left, need to flow everywhere except left
		return EFlowDir.U | EFlowDir.R | EFlowDir.D
	elif (isTL): # flow DR only
		return EFlowDir.R | EFlowDir.D
	elif (isTR): # flow DL only
		return EFlowDir.L | EFlowDir.D
	elif (isBL): # flow UR only
		return EFlowDir.U | EFlowDir.R
	elif (isBR): # flow UL only
		return EFlowDir.L | EFlowDir.U
	else:
		assert(false, "get_quadrant_flow_dir fail, no quadrant?")
	return 0

func clear() -> void:
	hintCellData = null;
	vaultGame.clear_all_hints()

func inv_flow_dir(flowDir:EFlowDir) -> EFlowDir:
	match flowDir:
		EFlowDir.L: return EFlowDir.R
		EFlowDir.U: return EFlowDir.D
		EFlowDir.R: return EFlowDir.L
		EFlowDir.D: return EFlowDir.U
	assert(false, "inv_flow_dir can't be done with no direction to inverse")
	return EFlowDir.O
		
func update_flow(flowCell:FlowCell) -> void:
	# add/update all cells in outflowdir
	if (DBG_flowCheck): print("update flow for %s - outdir=%s" % [flowCell.pos, flowCell.outFlowDir])
	var isFlowingL:bool = (flowCell.outFlowDir & EFlowDir.L == EFlowDir.L)
	var isFlowingU:bool = (flowCell.outFlowDir & EFlowDir.U == EFlowDir.U)
	var isFlowingR:bool = (flowCell.outFlowDir & EFlowDir.R == EFlowDir.R)
	var isFlowingD:bool = (flowCell.outFlowDir & EFlowDir.D == EFlowDir.D)
	if (isFlowingL): flow(flowCell, EFlowDir.L)
	if (isFlowingU): flow(flowCell, EFlowDir.U)
	if (isFlowingR): flow(flowCell, EFlowDir.R)
	if (isFlowingD): flow(flowCell, EFlowDir.D)
	flowCell.needFlow = false

func can_flow(originFlowCell:FlowCell, flowDir:EFlowDir) -> bool:
	var targetPos:Vector2i = originFlowCell.pos
	match flowDir:
		EFlowDir.L: targetPos += vL
		EFlowDir.U: targetPos += vU
		EFlowDir.R: targetPos += vR
		EFlowDir.D: targetPos += vD
	if ( !vaultGame.is_valid_pos(targetPos) ): return false
	if ( targetBounds.distance_to_pos(targetPos) > stepsLeft): return false
	var cellid:int = get_cell_id(targetPos)
	var cellData:CellData = vaultGame.allCellDatas[cellid]
	if (cellData.cellState == CellData.ECellState.SET && cellData.value != pushHintCurrentValue): return false
	if (cellData.cellState == CellData.ECellState.GUESS && cellData.guess != pushHintCurrentValue): return false
	return true
	
func flow(originFlowCell:FlowCell, flowDir:EFlowDir) -> void:
	if ( !can_flow(originFlowCell, flowDir) ):
		originFlowCell.possibleFlowDir &= ~flowDir
		originFlowCell.isDirty = true
		if (DBG_flowCheck): print("  can't flow in dir %s - possible %s" % [EFlowDir.find_key(flowDir), originFlowCell.possibleFlowDir])
		return
	var targetFlowDir:int = originFlowCell.outFlowDir
	var cancelDir:EFlowDir = inv_flow_dir(flowDir)
	targetFlowDir &= ~cancelDir
	var targetPos:Vector2i = originFlowCell.pos
	match flowDir:
		EFlowDir.L: targetPos += vL
		EFlowDir.U: targetPos += vU
		EFlowDir.R: targetPos += vR
		EFlowDir.D: targetPos += vD
	var targetFlowCell:FlowCell = get_flow_cell_at_pos(targetPos)
	if ( targetFlowCell == null ):
		if (DBG_flowCheck): print("  flowing %s to %s NEW dir=%s" % [originFlowCell.pos, targetPos, targetFlowDir])
		targetFlowCell = FlowCell.new(targetPos, flowDir, pushHintCurrentValue)
		targetFlowCell.set_out_flow_dir(targetFlowDir)
		newFlowCells.append(targetFlowCell)
	else:
		if (DBG_flowCheck): print("  flowing %s to %s EXISTS dir=%s" % [originFlowCell.pos, targetPos, targetFlowDir])
		targetFlowCell.fromDir |= flowDir
		#assert(targetFlowCell.outFlowDir & targetFlowDir != targetFlowDir, "expect flow to existing cell to be the same if origin was setup properly")
		#targetFlowCell.outFlowDir |= targetFlowDir

func get_cell_id(pos:Vector2i) -> int:
	return pos.y * vaultGame.boardXSize + pos.x
	
func update_hint() -> void:
	if ( hintUpdateFinished ): return
	
	if ( hintValues.size() > 0):
		pushHintCurrentValue = hintValues.pop_front()
		stepsLeft = hintValues.size()
		newFlowCells.clear()
		for flowCell:FlowCell in allFlowCells:
			if(flowCell.needFlow):
				update_flow(flowCell)
		allFlowCells.append_array(newFlowCells)
	
	var anyDirtyCell:bool = false
	for flowCell:FlowCell in allFlowCells:
		var cellid:int = get_cell_id(flowCell.pos)
		var cellData:CellData = vaultGame.allCellDatas[cellid]
		if ( flowCell.possibleFlowDir == 0 ):
			if (flowCell.isDirty):
				anyDirtyCell = true
				#if (flowCell.pos == Vector2i(4,1)):
					#print("4.1 dirty, possible flow %s" % flowCell.possibleFlowDir)
				cellData.cellRef.hide_hint_label()
				var isFromL:bool = (flowCell.fromDir & EFlowDir.L == EFlowDir.L)
				var isFromU:bool = (flowCell.fromDir & EFlowDir.U == EFlowDir.U)
				var isFromR:bool = (flowCell.fromDir & EFlowDir.R == EFlowDir.R)
				var isFromD:bool = (flowCell.fromDir & EFlowDir.D == EFlowDir.D)
				if (isFromL):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vL)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.L == EFlowDir.L):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.L
						fromFlowCell.isDirty = true
						if (DBG_flowCheck): print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.L), fromFlowCell.possibleFlowDir])
				if (isFromU):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vU)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.U == EFlowDir.U):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.U
						fromFlowCell.isDirty = true
						if (DBG_flowCheck): print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.U), fromFlowCell.possibleFlowDir])
				if (isFromR):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vR)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.R == EFlowDir.R):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.R
						fromFlowCell.isDirty = true
						if (DBG_flowCheck): print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.R), fromFlowCell.possibleFlowDir])
				if (isFromD):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vD)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.D == EFlowDir.D):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.D
						fromFlowCell.isDirty = true
						if (DBG_flowCheck): print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.D), fromFlowCell.possibleFlowDir])
			flowCell.isDirty = false
		elif ( cellData.cellState == CellData.ECellState.UNSET):
			#if (flowCell.pos == Vector2i(4,1)):
				#print("4.1 NOT dirty, possible flow %s" % flowCell.possibleFlowDir)
			cellData.cellRef.display_hint_label(flowCell.hintValue)
		else:
			match(flowCell.possibleFlowDir):
				EFlowDir.L: cellData.cellRef.display_flow(EFlowDir.L)
				EFlowDir.U: cellData.cellRef.display_flow(EFlowDir.U)
				EFlowDir.R: cellData.cellRef.display_flow(EFlowDir.R)
				EFlowDir.D: cellData.cellRef.display_flow(EFlowDir.D)
	
	hintUpdateFinished = !anyDirtyCell && (hintValues.size() == 0)


func process_codestr_to_hintValues(codestr:String) -> Array[int]:
	var result:Array[int] = []
	for digitchar:String in codestr:
		if digitchar.is_valid_int():
			result.push_back(digitchar.to_int())
	return result

func check_existing_path(currentPath:Array[CellData], currentCode:Array[int], step:int, originFlowDir:int) -> Array[CellData]:
	if ( currentPath.size() == currentCode.size() ): return currentPath # full path found
	if ( anyUnsetCell ): return currentPath # no need to check anymore, unset path
	# check last celldata of currentpath
	assert(currentPath.size() == step)
	var possibleCellDatas:Array[CellData] = get_existing_path_cellDatas(currentPath[step-1], currentCode[step], originFlowDir)
	#if (DBG_pathCheck): print("  found %s possible path at step %s" % [possibleCellDatas.size(), step])
	if ( possibleCellDatas.size() == 0 ): return currentPath # FAIL
	for cellData:CellData in possibleCellDatas:
		currentPath.append(cellData)
		if ( currentPath.size() == currentCode.size() ): return currentPath # full path found
		var altPath:Array[CellData] = currentPath.duplicate()
		altPath = check_existing_path(altPath, currentCode, step+1, originFlowDir)
		if ( altPath.size() == currentCode.size() ): return altPath # full path found
		var _result:int = currentPath.resize(currentPath.size() -1)
	return currentPath

var anyUnsetCell:bool # Hack: use as transient value for check_existing_path (can't return multiple values > could have done a context class that include this)
func check_path(pathOriginCellData:CellData) -> EPathResult:
	assert(pathOriginCellData.cellState == CellData.ECellState.SET, "check_existing_path only for set cells with a code")
	var cellsDataPath:Array[CellData] = []
	var pathHintValues:Array[int] = process_codestr_to_hintValues(pathOriginCellData.codeStr)
	cellsDataPath.append(pathOriginCellData)
	anyUnsetCell = false
	if (DBG_pathCheck): print("Path Check from %s" % pathOriginCellData.pos)
	
	cellsDataPath = check_existing_path(cellsDataPath, pathHintValues, 1, get_quadrant_flow_dir(pathOriginCellData))
	
	if (DBG_pathCheck): print("Path Check result size %s, unset? %s" % [cellsDataPath.size(), anyUnsetCell])
	if ( cellsDataPath.size() == pathHintValues.size() ): return EPathResult.SUCCESS
	if anyUnsetCell: return EPathResult.NONE
	if ( cellsDataPath.size() != pathHintValues.size() ): return EPathResult.INVALID
	return EPathResult.SUCCESS

func get_existing_path_cellDatas(pathOriginCellData:CellData, code:int, flowDir:int) -> Array[CellData]:
	var result:Array[CellData] = []
	var pos:Vector2i = pathOriginCellData.pos
	var isFlowingL:bool = (flowDir & EFlowDir.L == EFlowDir.L)
	var isFlowingU:bool = (flowDir & EFlowDir.U == EFlowDir.U)
	var isFlowingR:bool = (flowDir & EFlowDir.R == EFlowDir.R)
	var isFlowingD:bool = (flowDir & EFlowDir.D == EFlowDir.D)
	if ( isFlowingL ): result = add_to_path_if_valid(result, pos+vL, code)
	if ( isFlowingU ): result = add_to_path_if_valid(result, pos+vU, code)
	if ( isFlowingR ): result = add_to_path_if_valid(result, pos+vR, code)
	if ( isFlowingD ): result = add_to_path_if_valid(result, pos+vD, code)
	return result
		
	#for v:Vector2i in vDirs:
func add_to_path_if_valid(result:Array[CellData], pos:Vector2i, code:int) -> Array[CellData]:
	if(vaultGame.is_valid_pos(pos)):
		var cellId:int = get_cell_id(pos)
		var cellData:CellData = vaultGame.allCellDatas[cellId]
		if ( cellData.cellState == CellData.ECellState.SET && cellData.value == code):
			result.append(cellData)
		elif ( cellData.cellState == CellData.ECellState.GUESS && cellData.guess == code):
			result.append(cellData)
		elif (cellData.cellState == CellData.ECellState.UNSET):
			anyUnsetCell = true # Hack: set a member var to avoid adding a context (+ can't return multipla values)
	return result

#endregion
