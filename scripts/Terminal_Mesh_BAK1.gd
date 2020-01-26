extends Node2D

enum {
	FG_RID,
	BG_RID,
	RECT,
}

var verts = []
var uvs = []
var texture


var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

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
#	for i in range(GW*GH):
	pass


func _draw():
	draw_texture(texture, Vector2(), Color(1,1,1,1))

func init_cells():
	var img = load(data.font_path).get_data()
	img = utils.transparentisize_image(img)

	var itex = ImageTexture.new()
	itex.create_from_image(img)

	texture = MeshTexture.new()
	texture.base_texture = itex
	texture.image_size = get_viewport_rect().size # Vector2(100, 100)


#	var bg_glyph = 219
#	var bg_glyph_rect = Rect2(Vector2(bg_glyph%16, int(bg_glyph/16))*CS, Vector2(CS, CS))

#	for j in range(GH):
#		for i in range(GW):
#			pass

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array([
		Vector2(0,0),
		Vector2(10,0),
		Vector2(10,10),
		Vector2(0,0),
		Vector2(10,10),
		Vector2(0,10)
	])
#	arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array([
#		Vector2(0,0),
#		Vector2(1,0),
#		Vector2(1,1),
#		Vector2(0,0),
#		Vector2(1,1),
#		Vector2(0,1)
#	])
	arrays[Mesh.ARRAY_COLOR] = PoolColorArray([
		Color(1,0,0,1),
		Color(1,0,0,1),
		Color(1,0,0,1),
		Color(1,0,0,1),
		Color(1,0,0,1),
		Color(1,0,0,1)
	])

	var m = ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	texture.mesh = m

	update()





