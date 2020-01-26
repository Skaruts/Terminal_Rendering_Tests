extends Node2D

var glyphs:Array = []
var cell_rects:Array = []
var cell_glyphs:Array = []
var fg_colors:Array = []
var bg_colors:Array = []

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

var _font
var _fg = data.DEF_FG
var _bg = data.DEF_BG

func _init(gw, gh, cs, font):
	name = "Terminal_Draw"
	print("(GDScript) - initializing terminal - ", name )
	GW = gw
	GH = gh
	CS = cs
	_font = font
	init_cells()

func render():
	update()

func _draw():
	for i in range(GW*GH):
		draw_texture_rect_region( _font, cell_rects[i], glyphs[219], bg_colors[i])
		draw_texture_rect_region( _font, cell_rects[i], glyphs[cell_glyphs[i]], fg_colors[i])

func clear():
	for i in range(GW*GH):
		cell_glyphs[i] = 0
		fg_colors[i] = data.DEF_FG
		bg_colors[i] = data.DEF_BG

func set_fg(fg): _fg = fg
func set_bg(bg): _bg = bg

func put(x, y, glyph):
	var i = x+y*GW
	cell_glyphs[i] = glyph
	fg_colors[i] = _fg
	bg_colors[i] = _bg


func init_cells():
	print("(GDScript) - initializing cells")
	# precomputed texture regions
	for i in range(16*16): # tileset is 16x16 tiles wide/high
		glyphs.append( Rect2((i%16)*CS, (i/16)*CS, CS, CS) )

	for j in range(GH):
		for i in range(GW):
			cell_rects.append( Rect2(i*CS, j*CS, CS, CS) )
			fg_colors.append(Color(rand_range(0,1), 0, 0, rand_range(0,1)))
			bg_colors.append(Color(rand_range(0,1), 0, 0, rand_range(0,1)))
			cell_glyphs.append( utils.irand(0, 255) )
