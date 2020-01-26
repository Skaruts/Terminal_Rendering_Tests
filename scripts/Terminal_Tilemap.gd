extends TileMap

#var texture = load("res://assets/font1_24x24_a.png")

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size



func _ready():
	GW = get_parent().GW
	GH = get_parent().GH
	CS = get_parent().CS
	init_cells()
	set_process(false)


func _process(delta):
	randomize_cells()


func randomize_cells():
	for j in range(GH):
		for i in range(GW):
			set_cell(i, j, utils.irand(0, 255))


func init_cells():
	for j in range(GH):
		for i in range(GW):
			set_cell(i, j, utils.irand(0, 255))

