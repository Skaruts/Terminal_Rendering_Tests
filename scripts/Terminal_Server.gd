extends Node2D

var cells = []
#var _fg_cell_rids = []
#var _bg_cell_rids = []
#var _cell_rects = []
var _glyph_rects = []

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

var _fg = data.DEF_FG
var _bg = data.DEF_BG
var _font

func _init(gw, gh, cs, font):
	name = "Terminal_Server"
	print("(GDScript) - initializing terminal - ", name )
	GW = gw
	GH = gh
	CS = cs
	_font = font
	init_cells()

func render():
	for i in range(GW*GH):
		var cell = cells[i]
		VisualServer.canvas_item_clear(cell.bg_rid)
		VisualServer.canvas_item_clear(cell.fg_rid)
		VisualServer.canvas_item_add_texture_rect_region(cell.bg_rid, cell.rect, _font, _glyph_rects[219], cell.bg)
		VisualServer.canvas_item_add_texture_rect_region(cell.fg_rid, cell.rect, _font, _glyph_rects[cell.glyph], cell.fg)
	pass

func clear():
	for i in range(GW*GH):
		cells[i].glyph = 0
		cells[i].fg = data.DEF_FG
		cells[i].bg = data.DEF_BG

func set_fg(fg): _fg = fg
func set_bg(bg): _bg = bg

func put(x, y, glyph):
	var i = x+y*GW
	cells[i].glyph = glyph
	cells[i].fg = _fg
	cells[i].bg = _bg

func init_cells():
	# this isn't strictly needed in gdsctipt
	_font = VisualServer.texture_create_from_image(_font.get_data())

#	for j in range(16):
#		for i in range(16):
#			_glyph_rects.append( Rect2(i*CS, j*CS, CS, CS ) )

	for i in range(16*16): # tileset is 16x16 tiles wide/high
		_glyph_rects.append( Rect2(int(i % 16)*CS, int(i / 16)*CS, CS, CS) )

	for j in range(GH):
		for i in range(GW):
			var fg_rid = VisualServer.canvas_item_create()
			var bg_rid = VisualServer.canvas_item_create()
			var rect = Rect2(i*CS, j*CS, CS, CS)
			var glyph = utils.irand(0, 255)

			var cell = {
				fg_rid  = fg_rid,
				bg_rid  = bg_rid,
				rect    = rect,
				glyph   = glyph,
				fg      = data.DEF_FG,
				bg      = data.DEF_BG,
			}
			cells.append(cell)

			VisualServer.canvas_item_set_parent(cell.bg_rid, get_canvas_item())
			VisualServer.canvas_item_set_parent(cell.fg_rid, get_canvas_item())

			VisualServer.canvas_item_add_texture_rect_region(cell.bg_rid, cell.rect, _font, _glyph_rects[219], cell.bg)
			VisualServer.canvas_item_add_texture_rect_region(cell.fg_rid, cell.rect, _font, _glyph_rects[cell.glyph], cell.fg)


