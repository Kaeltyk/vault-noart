class_name CellData
extends Object

enum ECellState { UNSET, GUESS, SET, INVALID }

var cellState:ECellState = ECellState.INVALID
var cellRef:Cell
var cellId:int
var pos:Vector2i
#var cellx:int
#var celly:int
var quadrant:int
var oppositequadrant:int
var value:int
var guess:int = -1
var codeStr:String = ""
var codeSequence:Array[int] = []

func _init(_cellRef:Cell, _cellx:int, _celly:int, _cellId:int, _value:int, _quadrant:int, _oppositequadrant:int) -> void:
	self.cellRef = _cellRef
	self.pos.x = _cellx
	self.pos.y = _celly
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
