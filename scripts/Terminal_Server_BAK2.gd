extends Node2D

enum {
	FG_RID,
	BG_RID,
	RECT,
}

var cells = []

#var _fg_cell_rids = []
#var _bg_cell_rids = []
#var _cell_rects = []
var _glyph_rects = []

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

var texture

func _init(gw, gh, cs):
	GW = gw
	GH = gh
	CS = cs


func _ready():
	set_process(false)
	init_cells()


func _process(delta):
	randomize_cells()


func randomize_cells():
	for i in range(GW*GH):
		var cell = cells[i]
		var bg = rand_range(0,1)
		var fg = rand_range(0,1)

		VisualServer.canvas_item_clear(cell[BG_RID])
		VisualServer.canvas_item_clear(cell[FG_RID])

		VisualServer.canvas_item_add_texture_rect_region(cell[BG_RID], cell[RECT], texture, _glyph_rects[219])
		VisualServer.canvas_item_add_texture_rect_region(cell[FG_RID], cell[RECT], texture, _glyph_rects[utils.irand(0, 255)])
		VisualServer.canvas_item_set_modulate(cell[BG_RID], Color(bg, bg, 0, bg))
		VisualServer.canvas_item_set_modulate(cell[FG_RID], Color(fg, fg, 0, fg))



func init_cells():
	var img = load(data.font_path).get_data()
	img = utils.transparentisize_image(img)

	texture = VisualServer.texture_create_from_image(img)

	var bg_glyph = 219
	var bg_glyph_rect = Rect2(Vector2(bg_glyph%16, int(bg_glyph/16))*CS, Vector2(CS, CS))

	for j in range(GH):
		for i in range(GW):
			var fg_rid = VisualServer.canvas_item_create()
			var bg_rid = VisualServer.canvas_item_create()
			var rect = Rect2(i*CS, j*CS, CS, CS)

			cells.append([
				fg_rid,
				bg_rid,
				rect
			])

			var fg_glyph = utils.irand(0, 255)
			var fg_glyph_rect = Rect2( (fg_glyph%16)*CS, int(fg_glyph/16)*CS, CS, CS )
#			_glyph_rects.append( fg_glyph_rect )
			var bg = rand_range(0, 1)
			var fg = rand_range(0, 1)

			VisualServer.canvas_item_set_parent(bg_rid, get_canvas_item())
			VisualServer.canvas_item_set_parent(fg_rid, get_canvas_item())

			VisualServer.canvas_item_add_texture_rect_region(bg_rid, rect, texture, bg_glyph_rect)
			VisualServer.canvas_item_add_texture_rect_region(fg_rid, rect, texture, fg_glyph_rect)

			VisualServer.canvas_item_set_modulate(bg_rid, Color(bg, bg, 0, bg))
			VisualServer.canvas_item_set_modulate(fg_rid, Color(fg, fg, 0, fg))


	for i in range(256):
		var x = i%16
		var y = int(i/16)
		_glyph_rects.append( Rect2( Vector2(x, y)*CS, Vector2(CS, CS) ) )

