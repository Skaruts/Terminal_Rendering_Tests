extends Node2D

# TODO: precompute uvs

var DEF_FG = Color("808080")
var DEF_BG = Color(0,0,0,1)

var fg_mesh_instance
#var bg_mesh_instance

var UVS = 1.0/16.0   # uv size

var fg_verts = []#PoolVector2Array()
var fg_uvs = []#PoolVector2Array()
var fg_cols = []#PoolColorArray()
var fg_inds = []#PoolIntArray()

var bg_verts = []#PoolVector2Array()
var bg_uvs = []#PoolVector2Array()
var bg_cols = []#PoolColorArray()
var bg_inds = []#PoolIntArray()

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

func clear():
	for j in range(GH):
		for i in range(GW):
			put(i, j, 249, DEF_FG, DEF_BG)


func put(x, y, glyph, fg, bg):
	if x >= 0 and y >= 0 and x < GW and y < GH:
		var i = (x+y*GW)*4

#	if glyph != null:
		var u = (glyph % 16)*UVS
		var v = (glyph / 16)*UVS
		var u2 = u + UVS
		var v2 = v + UVS

		fg_uvs[i+0] = Vector2( u , v  )
		fg_uvs[i+1] = Vector2( u2, v  )
		fg_uvs[i+2] = Vector2( u2, v2 )
		fg_uvs[i+3] = Vector2( u , v2 )

#	if fg != null:
		fg_cols[i+0] = fg
		fg_cols[i+1] = fg
		fg_cols[i+2] = fg
		fg_cols[i+3] = fg

#	if bg != null:
		bg_cols[i+0] = bg
		bg_cols[i+1] = bg
		bg_cols[i+2] = bg
		bg_cols[i+3] = bg

func update_mesh():
	var fg_arrays := []
	fg_arrays.resize(Mesh.ARRAY_MAX)
	fg_arrays[Mesh.ARRAY_INDEX] = PoolIntArray(fg_inds)
	fg_arrays[Mesh.ARRAY_VERTEX] = PoolVector2Array(fg_verts)
	fg_arrays[Mesh.ARRAY_TEX_UV] = PoolVector2Array(fg_uvs)
	fg_arrays[Mesh.ARRAY_COLOR] = PoolColorArray(fg_cols)

	var fg_m = ArrayMesh.new()
	fg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, fg_arrays)
	fg_mesh_instance.mesh = fg_m


#	var bg_arrays := []
#	bg_arrays.resize(Mesh.ARRAY_MAX)
#	bg_arrays[Mesh.ARRAY_INDEX] = bg_inds
#	bg_arrays[Mesh.ARRAY_VERTEX] = bg_verts
#	bg_arrays[Mesh.ARRAY_TEX_UV] = bg_uvs
#	bg_arrays[Mesh.ARRAY_COLOR] = bg_cols
#
#	var bg_m = ArrayMesh.new()
#	bg_m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bg_arrays)
#	bg_mesh_instance.mesh = bg_m




func init_cells():
	print("initializing cells")

	var img = load(data.font_path).get_data()
	img = utils.transparentisize_image(img)
	var itex = ImageTexture.new()
	itex.create_from_image(img)
#	var itex2 = ImageTexture.new()
#	itex2.create_from_image(img)
#	bg_mesh_instance = MeshInstance2D.new()
#	bg_mesh_instance.name = "bg_mesh_instance"
#	bg_mesh_instance.texture = itex
#	add_child(bg_mesh_instance)

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

			add_fg_quad(idx, a, b, c, d, 64, DEF_FG)
#			add_bg_quad(idx, a, b, c, d, 35, DEF_BG)
			idx += 4

	update_mesh()


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

#	fg_inds.append_array([i+0, i+1, i+2, i+0, i+2, i+3])
	fg_inds += [i+0, i+1, i+2, i+0, i+2, i+3]

#func add_bg_quad(i, a, b, c, d, glyph, color):
#	var u = int(glyph % 16)*UVS
#	var v = int(glyph / 16)*UVS
#	var u2 = u + UVS
#	var v2 = v + UVS
#	var ua = Vector2( u , v  )
#	var ub = Vector2( u2, v  )
#	var uc = Vector2( u2, v2 )
#	var ud = Vector2( u , v2 )
#
#	add_bg_vert(a, ua, color)
#	add_bg_vert(b, ub, color)
#	add_bg_vert(c, uc, color)
#	add_bg_vert(d, ud, color)
#
#	bg_inds.append_array([i+0, i+1, i+2, i+0, i+2, i+3])

func add_fg_vert(v, uv, c):
	fg_verts.append(v)
	fg_uvs.append(uv)
	fg_cols.append(c)

#func add_bg_vert(v, uv, c):
#	bg_verts.append(v)
#	bg_uvs.append(uv)
#	bg_cols.append(c)
#




