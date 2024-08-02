class_name Bounds2i
extends Object

# Helper class to handle int (grid) bound values

var xmin:int
var xmax:int
var ymin:int
var ymax:int

func get_rand_vec2i_in_bounds_except(except:Vector2i) -> Vector2i:
	assert(!(xmin == xmax && xmin == except.x && ymin == ymax && ymin == except.y), "get_rand_vec2i_in_bounds_except can't run if only one cell in bound equal to the excepted value")
	var x:int = randi_range(xmin, xmax)
	var y:int = randi_range(ymin, ymax)
	var safe:int = 99
	while (x==except.x && y==except.y && safe > 0):
		safe -= 1
		x = randi_range(xmin, xmax)
		y = randi_range(ymin, ymax)
	return Vector2i(x, y)
