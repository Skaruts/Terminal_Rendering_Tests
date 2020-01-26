extends Node
class_name GameCameraGDS

var x:int  # camera global coordinates
var y:int
var w:int
var h:int

var mx:int  # map coordinates
var my:int

var _min_x:int = -9999
var _min_y:int = -9999
var _max_x:int = 9999
var _max_y:int = 9999


func _init(nx:int, ny:int, nw:int, nh:int) -> void:
	x = nx
	y = ny
	w = nw
	h = nh


func move(tx:int, ty:int):
	mx = clamp(tx - w/2, _min_x, _max_x - w)
	my = clamp(ty - h/2, _min_y, _max_y - h)
#	mx = max( min(tx - w / 2, _max_x - w), _min_x)
#	my = max( min(ty - h / 2, _max_y - h), _min_y)


# convert object's map coordinates to camera coordinates
func to_cam_coords(ox:int, oy:int):
	var p := Vector2( ox-mx+x, oy-my+y )
	if p.x >= x and p.y >= x and p.x < x + w and p.y < y + h:
		return p
	return null


func set_limits(min_x:int, min_y:int, max_x:int, max_y:int):
	_min_x = min_x
	_min_y = min_x
	_max_x = max_x
	_max_y = max_y
