extends Node2D

#enum {
#	FG_RID,
#	BG_RID,
#	RECT,
#	GLYPH_RECT
#}
#
#var cells = []

var _fg_cell_rids = []
var _bg_cell_rids = []
var _cell_rects = []
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
		var fg_cell_rid = _fg_cell_rids[i]
		var bg_cell_rid = _bg_cell_rids[i]

		VisualServer.canvas_item_clear(bg_cell_rid)
		VisualServer.canvas_item_clear(fg_cell_rid)
		VisualServer.canvas_item_add_texture_rect_region(bg_cell_rid, _cell_rects[i], texture, _glyph_rects[219])
		VisualServer.canvas_item_add_texture_rect_region(fg_cell_rid, _cell_rects[i], texture, _glyph_rects[utils.irand(0, 255)])
		var bg = rand_range(0,1)
		var fg = rand_range(0,1)
		VisualServer.canvas_item_set_modulate(bg_cell_rid, Color(bg, bg, 0, bg))
		VisualServer.canvas_item_set_modulate(fg_cell_rid, Color(fg, fg, 0, fg))


func init_cells():
	var img = load(data.font_path).get_data()
	img = utils.transparentisize_image(img)

	texture = VisualServer.texture_create_from_image(img)

	var bg_glyph = 219
	var bg_glyph_rect = Rect2(Vector2(bg_glyph%16, int(bg_glyph/16))*CS, Vector2(CS, CS))

	for j in range(GH):
		for i in range(GW):
			#var idx = i+j*GW
			var fg_glyph = utils.irand(0, 255)
			var bg = rand_range(0,1)
			var fg = rand_range(0,1)
			var fg_glyph_rect = Rect2(Vector2(fg_glyph%16, int(fg_glyph/16))*CS, Vector2(CS, CS))
			var rect = Rect2(Vector2(i, j)*CS, Vector2(CS, CS))
			_cell_rects.append(rect)

			var bg_cell_rid = VisualServer.canvas_item_create()
			print(bg_cell_rid)
			VisualServer.canvas_item_set_parent(bg_cell_rid, get_canvas_item())
			VisualServer.canvas_item_add_texture_rect_region(bg_cell_rid, rect, texture, bg_glyph_rect)
			VisualServer.canvas_item_set_modulate(bg_cell_rid, Color(bg, bg, 0, bg))
			_bg_cell_rids.append(bg_cell_rid)

			var fg_cell_rid = VisualServer.canvas_item_create()
			VisualServer.canvas_item_set_parent(fg_cell_rid, get_canvas_item())
			VisualServer.canvas_item_add_texture_rect_region(fg_cell_rid, rect, texture, fg_glyph_rect)
			VisualServer.canvas_item_set_modulate(fg_cell_rid, Color(fg, fg, 0, fg))
			_fg_cell_rids.append(fg_cell_rid)


	for i in range(256):
		var x = i%16
		var y = int(i/16)
		_glyph_rects.append( Rect2( Vector2(x, y)*CS, Vector2(CS, CS) ) )
