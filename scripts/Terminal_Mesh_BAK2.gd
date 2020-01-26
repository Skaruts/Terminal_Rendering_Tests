extends Node2D

var fg_mesh_instance
var bg_mesh_instance

var UVS = 1.0/16.0   # uv size

var fg_verts = []
var fg_uvs = []
var fg_cols = []
var fg_inds = []

var bg_verts = []
var bg_uvs = []
var bg_cols = []
var bg_inds = []

var GW:int    # grid width
var GH:int    # grid height
var CS:int    # cell size

func _init(gw, gh, cs):
	print("initializing terminal")
	GW = gw
	GH = gh
	CS = cs
	init_cells()


func _ready():
	set_process(false)


func update_mesh():
	var fg_arrays := []
	fg_arrays.resize(Mesh.ARRAY_MAX)
	fg_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(fg_inds)
	fg_arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array(fg_verts)
	fg_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(fg_uvs)
	fg_arrays[Mesh.ARRAY_COLOR] = PoolColorArray(fg_cols)

	var bg_arrays := []
	bg_arrays.resize(Mesh.ARRAY_MAX)
	bg_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(bg_inds)
	bg_arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array(bg_verts)
	bg_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(bg_uvs)
	bg_arrays[Mesh.ARRAY_COLOR] = PoolColorArray(bg_cols)

	var fg_m = ArrayMesh.new()
	var bg_m = ArrayMesh.new()
	fg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, fg_arrays)
	bg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bg_arrays)
	fg_mesh_instance.mesh = fg_m
	bg_mesh_instance.mesh = bg_m

func _process(delta):
	randomize_cells()

func randomize_cells():
	for j in range(GH):
		for i in range(GW):
			var fg = rand_range(0, 1)
			var bg = rand_range(0, 1)
			put(i, j, utils.irand(0, 255), Color(0,fg,fg,fg), Color(0,bg,bg,bg))
#			put(i, j, 254, Color(0,fg,fg,fg), Color(0,bg,bg,bg))
	update_mesh()

func init_cells():
	print("initializing cells")

	var img = load(data.font_path).get_data()
	img = utils.transparentisize_image(img)
	var itex = ImageTexture.new()
	itex.create_from_image(img)

	bg_mesh_instance = MeshInstance2D.new()
	bg_mesh_instance.name = "bg_mesh_instance"
	bg_mesh_instance.texture = itex
	add_child(bg_mesh_instance)

	fg_mesh_instance = MeshInstance2D.new()
	fg_mesh_instance.name = "fg_mesh_instance"
	fg_mesh_instance.texture = itex
	add_child(fg_mesh_instance)

	var idx = 0
	for j in range(GH):
		for i in range(GW):
			var a = Vector2( i    * CS,  j    * CS)
			var b = Vector2((i+1) * CS,  j    * CS)
			var c = Vector2((i+1) * CS, (j+1) * CS)
			var d = Vector2(  i   * CS, (j+1) * CS)

			var fg = rand_range(0, 1)
			var bg = rand_range(0, 1)
			var fg_glyph = utils.irand(0, 255)
			add_fg_quad(idx, a, b, c, d, fg_glyph, Color(0,fg,fg,fg))
			add_bg_quad(idx, a, b, c, d, 219, Color(0,bg,bg,bg))
			idx += 4

#	update_mesh()
	var fg_arrays := []
	fg_arrays.resize(Mesh.ARRAY_MAX)
	fg_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(fg_inds)
	fg_arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array(fg_verts)
	fg_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(fg_uvs)
	fg_arrays[Mesh.ARRAY_COLOR] = PoolColorArray(fg_cols)



	var bg_arrays := []
	bg_arrays.resize(Mesh.ARRAY_MAX)
	bg_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(bg_inds)
	bg_arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array(bg_verts)
	bg_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(bg_uvs)
	bg_arrays[Mesh.ARRAY_COLOR] = PoolColorArray(bg_cols)

	var fg_m = ArrayMesh.new()
	var bg_m = ArrayMesh.new()
	fg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, fg_arrays)
	bg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bg_arrays)
	fg_mesh_instance.mesh = fg_m
	bg_mesh_instance.mesh = bg_m





func add_fg_quad(i, a, b, c, d, glyph, color):
	var u = int(glyph % 16)*UVS
	var v = int(glyph / 16)*UVS
	var u2 = u + UVS
	var v2 = v + UVS
	var ua = Vector2( u , v  )
	var ub = Vector2( u2, v  )
	var uc = Vector2( u2, v2 )
	var ud = Vector2( u , v2 )

	add_fg_vert(a, ua, color)
	add_fg_vert(b, ub, color)
	add_fg_vert(c, uc, color)
	add_fg_vert(d, ud, color)

	fg_inds += [i+0, i+1, i+2, i+0, i+2, i+3]

func add_bg_quad(i, a, b, c, d, glyph, color):
	var u = int(glyph % 16)*UVS
	var v = int(glyph / 16)*UVS
	var u2 = u + UVS
	var v2 = v + UVS
	var ua = Vector2( u , v  )
	var ub = Vector2( u2, v  )
	var uc = Vector2( u2, v2 )
	var ud = Vector2( u , v2 )

	add_bg_vert(a, ua, color)
	add_bg_vert(b, ub, color)
	add_bg_vert(c, uc, color)
	add_bg_vert(d, ud, color)

	bg_inds += [i+0, i+1, i+2, i+0, i+2, i+3]

func add_fg_vert(v, uv, c):
	fg_verts.append(v)
	fg_uvs.append(uv)
	fg_cols.append(c)

func add_bg_vert(v, uv, c):
	bg_verts.append(v)
	bg_uvs.append(uv)
	bg_cols.append(c)




func put(x, y, glyph, fg, bg):
	var i = (x+y*GW)*4
	var u = int(glyph % 16)*UVS
	var v = int(glyph / 16)*UVS
	var u2 = u + UVS
	var v2 = v + UVS

	fg_uvs[i+0] = Vector2( u , v  )
	fg_uvs[i+1] = Vector2( u2, v  )
	fg_uvs[i+2] = Vector2( u2, v2 )
	fg_uvs[i+3] = Vector2( u , v2 )

	fg_cols[i+0] = fg
	fg_cols[i+1] = fg
	fg_cols[i+2] = fg
	fg_cols[i+3] = fg

	bg_cols[i+0] = bg
	bg_cols[i+1] = bg
	bg_cols[i+2] = bg
	bg_cols[i+3] = bg
