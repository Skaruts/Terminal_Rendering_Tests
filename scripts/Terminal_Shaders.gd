extends Node2D

var cells:Array = []
var _fg
var _bg
var _font

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

func _init(gw, gh, cs, font):
	name = "Terminal_Shaders"
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
		cells[i].frame = 0
		cells[i].material.set_shader_param("fg", data.DEF_FG)
		cells[i].material.set_shader_param("bg", data.DEF_BG)

func set_fg(fg): _fg = fg
func set_bg(bg): _bg = bg

func put(x, y, glyph):
	var i = x+y*GW
	cells[i].frame = glyph
	cells[i].material.set_shader_param("fg", _fg)
	cells[i].material.set_shader_param("bg", _bg)

func init_cells():
	var shader = load("res://resources/cell_shader.shader")

	# main cells (64x40)
	for j in range(GH):
		for i in range(GW):
			var cell = Sprite.new()
			add_child(cell)
			cells.append(cell)

			cell.centered = false
			cell.texture = _font
			cell.vframes = 16
			cell.hframes = 16
			cell.frame = utils.irand(0, 255)
			cell.position = Vector2(i*CS, j*CS)

			cell.material = ShaderMaterial.new()
			cell.material.shader = shader
			cell.material.set_shader_param("fg", data.DEF_FG)
			cell.material.set_shader_param("bg", data.DEF_BG)
