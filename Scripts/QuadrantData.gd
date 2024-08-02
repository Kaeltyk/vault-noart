class_name QuadrantData
extends Object

enum EQuadrant { TOPLEFT=1<<0, TOPRIGHT=1<<1, BOTTOMLEFT=1<<2, BOTTOMRIGHT=1<<3, INVALID=0 }

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
	#print("quadrant setup: size %s x %s, XL=0..%s, YT=0..%s, XR=%s..%s, YB=%s..%s" % [xSize, ySize, leftXMax, topYMax, rightXMin, xSize-1, bottomYMin, ySize-1])
func get_quadrant(x:int, y:int) -> int:
	var result:int = EQuadrant.INVALID
	if x<=leftXMax:
		if y<=topYMax: result |= EQuadrant.TOPLEFT
		if y>=bottomYMin: result |= EQuadrant.BOTTOMLEFT
	if x>=rightXMin:
		if y<=topYMax: result |= EQuadrant.TOPRIGHT
		if y>=bottomYMin: result |= EQuadrant.BOTTOMRIGHT
	assert(result != EQuadrant.INVALID, "get_quadrant fail")
	#print("quadrant query for %s x %s > %s" % [x, y, result])
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
