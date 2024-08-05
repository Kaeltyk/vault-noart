class_name HintFill
extends Object

#region other algorithm - flood fill with directional flow & filtering existing cells if not matching code

enum EFlowDir { U=1<<0, R=1<<1, L=1<<2, D=1<<3, O=1<<4 }
const vU:Vector2i = Vector2i(0, -1)
const vD:Vector2i = Vector2i(0, 1)
const vL:Vector2i = Vector2i(-1, 0)
const vR:Vector2i = Vector2i(1, 0)

var hintCellData:CellData
var hintValues:Array[int] = []
var targetBounds:Bounds2i
var vaultGame:VaultGame

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

#var processCell:Array[Vector2i] = []
#var processCellDir:Array[int] = []
#var processCellNew:Array[Vector2i] = []
#var processCellDirNew:Array[int] = []

var allFlowCells:Array[FlowCell] = []
var newFlowCells:Array[FlowCell] = []

var pushHintCurrentValue:int
var stepsLeft:int
var hintUpdateFinished:bool = true

func _init(game:VaultGame) -> void:
	vaultGame = game

func start_hint(startCellData:CellData) -> void:
	if (hintCellData == startCellData):
		clear()
		#update_hint()
		return
		
	hintCellData = startCellData
	targetBounds = vaultGame.quadrantData.get_quadrant_Bounds2i(hintCellData.oppositequadrant)
	allFlowCells.clear()
	#processCell.clear()
	#processCellDir.clear()
	#processCell.append(Vector2i(startCellData.cellx, startCellData.celly))
	#processCellDir.append(EFlowDir.O)
	process_codestr_to_hintValues(hintCellData.codeStr)
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
	var startFlowCell:FlowCell = FlowCell.new(Vector2i(hintCellData.cellx, hintCellData.celly), EFlowDir.O, pushHintCurrentValue)
	var quadrant:int = hintCellData.quadrant
	var isTL:bool = (quadrant & QuadrantData.EQuadrant.TOPLEFT == QuadrantData.EQuadrant.TOPLEFT)
	var isTR:bool = (quadrant & QuadrantData.EQuadrant.TOPRIGHT == QuadrantData.EQuadrant.TOPRIGHT)
	var isBL:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMLEFT == QuadrantData.EQuadrant.BOTTOMLEFT)
	var isBR:bool = (quadrant & QuadrantData.EQuadrant.BOTTOMRIGHT == QuadrantData.EQuadrant.BOTTOMRIGHT)
	if (isTL && isTR && isBL && isBR): # center, need to flow in all directions
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.U | EFlowDir.R | EFlowDir.D)
	elif (isTL && isTR): # center top, need to flow everywhere except up
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.R | EFlowDir.D)
	elif (isTR && isBR): # center right, need to flow everywhere except right
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.U | EFlowDir.D)
	elif (isBR && isBL): # center bottom, need to flow everywhere except down
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.U | EFlowDir.R)
	elif (isBL && isTL): # center left, need to flow everywhere except left
		startFlowCell.set_out_flow_dir(EFlowDir.U | EFlowDir.R | EFlowDir.D)
	elif (isTL): # flow DR only
		startFlowCell.set_out_flow_dir(EFlowDir.R | EFlowDir.D)
	elif (isTR): # flow DL only
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.D)
	elif (isBL): # flow UR only
		startFlowCell.set_out_flow_dir(EFlowDir.U | EFlowDir.R)
	elif (isBR): # flow UL only
		startFlowCell.set_out_flow_dir(EFlowDir.L | EFlowDir.U)
	else:
		assert(false, "push_from_origin fail, no quadrant?")
	allFlowCells.append(startFlowCell)

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
	#print("update flow for %s - outdir=%s" % [flowCell.pos, flowCell.outFlowDir])
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
	var cellid:int = targetPos.y*vaultGame.boardXSize+targetPos.x
	var cellData:CellData = vaultGame.allCellDatas[cellid]
	if (cellData.cellState == CellData.ECellState.SET && cellData.value != pushHintCurrentValue): return false
	if (cellData.cellState == CellData.ECellState.GUESS && cellData.guess != pushHintCurrentValue): return false
	return true
	
func flow(originFlowCell:FlowCell, flowDir:EFlowDir) -> void:
	#var backdir:EFlowDir = inv_flow_dir(flowDir)
	#if ( originFlowCell.fromDir & backdir == backdir): return # don't go back to any cell we can come from
	if ( !can_flow(originFlowCell, flowDir) ):
		originFlowCell.possibleFlowDir &= ~flowDir
		originFlowCell.isDirty = true
		#print("  can't flow in dir %s - possible %s" % [EFlowDir.find_key(flowDir), originFlowCell.possibleFlowDir])
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
		#print("  flowing %s to %s NEW dir=%s" % [originFlowCell.pos, targetPos, targetFlowDir])
		targetFlowCell = FlowCell.new(targetPos, flowDir, pushHintCurrentValue)
		targetFlowCell.set_out_flow_dir(targetFlowDir)
		newFlowCells.append(targetFlowCell)
	else:
		#print("  flowing %s to %s EXISTS dir=%s" % [originFlowCell.pos, targetPos, targetFlowDir])
		targetFlowCell.fromDir |= flowDir
		#assert(targetFlowCell.outFlowDir & targetFlowDir != targetFlowDir, "expect flow to existing cell to be the same if origin was setup properly")
		#targetFlowCell.outFlowDir |= targetFlowDir
			
				

func update_hint() -> void:
	if ( hintUpdateFinished ): return
	
	if ( hintValues.size() > 0):
		pushHintCurrentValue = hintValues.pop_front()
		stepsLeft = hintValues.size()
		newFlowCells.clear()
		for flowCell:FlowCell in allFlowCells:
			if(flowCell.needFlow):
				update_flow(flowCell)
	#vaultGame.update_hints_for_cells(allFlowCells, pushHintCurrentValue)
		allFlowCells.append_array(newFlowCells)
	
	var anyDirtyCell:bool = false
	for flowCell:FlowCell in allFlowCells:
		var cellid:int = flowCell.pos.y * vaultGame.boardXSize + flowCell.pos.x
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
						#print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.L), fromFlowCell.possibleFlowDir])
				if (isFromU):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vU)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.U == EFlowDir.U):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.U
						fromFlowCell.isDirty = true
						#print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.U), fromFlowCell.possibleFlowDir])
				if (isFromR):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vR)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.R == EFlowDir.R):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.R
						fromFlowCell.isDirty = true
						#print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.R), fromFlowCell.possibleFlowDir])
				if (isFromD):
					var fromFlowCell:FlowCell = get_flow_cell_at_pos(flowCell.pos - vD)
					assert(fromFlowCell != null, "dirty flowcell can't find it's 'from' ?!")
					if (fromFlowCell.possibleFlowDir & EFlowDir.D == EFlowDir.D):
						fromFlowCell.possibleFlowDir &= ~EFlowDir.D
						fromFlowCell.isDirty = true
						#print("  cancel flow from %s in dir %s - possible %s" % [fromFlowCell.pos, EFlowDir.find_key(EFlowDir.D), fromFlowCell.possibleFlowDir])
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


func process_codestr_to_hintValues(codestr:String) -> void:
	hintValues.clear()
	for digitchar:String in codestr:
		if digitchar.is_valid_int():
			hintValues.push_back(digitchar.to_int())
	#var _removed:int = hintValues.pop_front() # remove the hacked cell value that is the first code digit

#endregion
