extends Node2D

var fg_cells:Array = []
var bg_cells:Array = []
var _font
var _fg = data.DEF_FG
var _bg = data.DEF_BG

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # fg_cell size

func _init(gw, gh, cs, font):
	name = "Terminal_Sprites"
	print("(GDScript) - initializing terminal - ", name )
	GW = gw
	GH = gh
	CS = cs
	_font = font
	init_cells()

func render():
	pass

func clear():
	for i in range(GW*GH):
		fg_cells[i].frame = 0
		fg_cells[i].modulate = data.DEF_FG
		bg_cells[i].modulate = data.DEF_BG

func set_fg(fg): _fg = fg
func set_bg(bg): _bg = bg
func put(x, y, glyph):
	var i = x+y*GW
	fg_cells[i].frame = glyph
	fg_cells[i].modulate = _fg
	bg_cells[i].modulate = _bg

func init_cells():
	print("(GDScript) - initializing cells")
	# main fg_cells (64x40)
	for j in range(GH):
		for i in range(GW):
			var pos = Vector2(i*CS, j*CS)

			# background
			var bg_cell = Sprite.new()
			add_child(bg_cell)
			bg_cells.append(bg_cell)

			bg_cell.centered = false
			bg_cell.texture = _font
			bg_cell.vframes = 16
			bg_cell.hframes = 16
			bg_cell.frame = 219
			bg_cell.position = pos

			var bg = rand_range(0, 1)
			bg_cell.modulate = Color(0, 0, bg, bg)


			# foreground
			var fg_cell = Sprite.new()
			add_child(fg_cell)
			fg_cells.append(fg_cell)

			fg_cell.centered = false
			fg_cell.texture = _font
			fg_cell.vframes = 16
			fg_cell.hframes = 16
			fg_cell.frame = utils.irand(0, 255)
			fg_cell.position = pos

			var fg = rand_range(0, 1)
			fg_cell.modulate = Color(0, 0, fg, fg)


