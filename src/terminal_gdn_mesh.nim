import random
import gdw
import godot
import godotapi/[
    godottypes,
    texture,
    # resource_loader,
    mesh_instance_2d,
    mesh,
    array_mesh,
    # resource,
    node_2d
]

const DEF_FG = col(0.75, 0.75, 0.75, 1)
const DEF_BG = col(0, 0, 0, 1)
const UVS = 1.0/16.0  # uv size

gdobj Terminal_GDN_Sprites of Node2D:
    var GW:int
    var GH:int
    var CS:int
    var fg:Color = DEF_FG
    var bg:Color = DEF_BG
    var font:Texture

    var fg_cells: seq[Sprite]
    var bg_cells: seq[Sprite]


    proc initialize*(gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.name = "Terminal_GDN_Mesh"
        print("(GDNative) - initializing terminal: ", self.name)
        randomize()
        self.GW = gw
        self.GH = gh
        self.CS = cs
        self.font = font

        self.init_cells()

    proc render*() {.gdExport.} =
        self.update_mesh()

    proc clear*() {.gdExport.} =
        for j in 0..<self.GH:
            for i in 0..<self.GW:
                self.fg = DEF_FG
                self.bg = DEF_BG
                self.put(i, j, 0)

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc put*(x, y, glyph:int) {.gdExport.} =
        if x >= 0 and y >= 0 and x < self.GW and y < self.GH:
            let i = (x+y*self.GW)*4
            let u = float(glyph mod 16) * UVS
            let v = float(glyph div 16) * UVS
            var u2 = u + UVS
            var v2 = v + UVS

            self.fg_uvs[i+0] = vec2(  u,  v )
            self.fg_uvs[i+1] = vec2( u2,  v )
            self.fg_uvs[i+2] = vec2( u2, v2 )
            self.fg_uvs[i+3] = vec2(  u, v2 )

            self.fg_cols[i+0] = self.fg
            self.fg_cols[i+1] = self.fg
            self.fg_cols[i+2] = self.fg
            self.fg_cols[i+3] = self.fg

            self.bg_cols[i+0] = self.bg
            self.bg_cols[i+1] = self.bg
            self.bg_cols[i+2] = self.bg
            self.bg_cols[i+3] = self.bg


    proc init_cells() =
        print("(GDN) - initializing cells")
        self.fg_verts = newPoolVector2Array()
        self.fg_uvs   = newPoolVector2Array()
        self.fg_cols  = newPoolColorArray()
        self.fg_inds  = newPoolIntArray()
        self.bg_verts = newPoolVector2Array()
        self.bg_uvs   = newPoolVector2Array()
        self.bg_cols  = newPoolColorArray()
        self.bg_inds  = newPoolIntArray()

        self.bg_mesh_instance = gdnew[MeshInstance2D]()
        self.bg_mesh_instance.name = "bg_mesh_instance"
        self.bg_mesh_instance.texture = self.font
        self.add_child(self.bg_mesh_instance)

        self.fg_mesh_instance = gdnew[MeshInstance2D]()
        self.fg_mesh_instance.name = "fg_mesh_instance"
        self.fg_mesh_instance.texture = self.font
        self.add_child(self.fg_mesh_instance)

        var idx = 0
        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let a = vec2(  i    * self.CS,  j    * self.CS )
                let b = vec2( (i+1) * self.CS,  j    * self.CS )
                let c = vec2( (i+1) * self.CS, (j+1) * self.CS )
                let d = vec2(  i    * self.CS, (j+1) * self.CS )

                self.add_fg_quad(idx, a, b, c, d, 64, DEF_FG)
                self.add_bg_quad(idx, a, b, c, d, 219, DEF_FG)

                idx += 4
        self.update_mesh()

    proc add_fg_quad(i:int, a, b, c, d:Vector2, glyph:int, color:Color) =
        let u = float(glyph mod 16)*UVS
        let v = float(glyph div 16)*UVS
        let u2 = u + UVS
        let v2 = v + UVS

        let ua = vec2(  u,  v )
        let ub = vec2( u2,  v )
        let uc = vec2( u2, v2 )
        let ud = vec2(  u, v2 )

        self.add_fg_vert(a, ua, color)
        self.add_fg_vert(b, ub, color)
        self.add_fg_vert(c, uc, color)
        self.add_fg_vert(d, ud, color)

        for idx in [i+0, i+1, i+2, i+0, i+2, i+3]:
            self.fg_inds.add(cint(idx))

    proc add_bg_quad(i:int, a, b, c, d:Vector2, glyph:int, color:Color) =
        let u = float(glyph mod 16)*UVS
        let v = float(glyph div 16)*UVS
        let u2 = u + UVS
        let v2 = v + UVS

        let ua = vec2(  u,  v )
        let ub = vec2( u2,  v )
        let uc = vec2( u2, v2 )
        let ud = vec2(  u, v2 )

        self.add_bg_vert(a, ua, color)
        self.add_bg_vert(b, ub, color)
        self.add_bg_vert(c, uc, color)
        self.add_bg_vert(d, ud, color)

        for idx in [i+0, i+1, i+2, i+0, i+2, i+3]:
            self.bg_inds.add(cint(idx))

    proc add_fg_vert(v, uv:Vector2, c:Color) =
        self.fg_verts.add(v)
        self.fg_uvs.add(uv)
        self.fg_cols.add(c)

    proc add_bg_vert(v, uv:Vector2, c:Color) =
        self.bg_verts.add(v)
        self.bg_uvs.add(uv)
        self.bg_cols.add(c)


    proc update_mesh() =
        var fg_arrays = newArray()
        fg_arrays.set_len(int(mesh.ARRAY_MAX))
        fg_arrays[int(mesh.ARRAY_INDEX)]  = toVariant(self.fg_inds)
        fg_arrays[int(mesh.ARRAY_VERTEX)] = toVariant(self.fg_verts)
        fg_arrays[int(mesh.ARRAY_TEX_UV)] = toVariant(self.fg_uvs)
        fg_arrays[int(mesh.ARRAY_COLOR)]  = toVariant(self.fg_cols)

        var fg_m = gdnew[ArrayMesh]()
        fg_m.add_surface_from_arrays(mesh.PRIMITIVE_TRIANGLES, fg_arrays)
        self.fg_mesh_instance.mesh = fg_m


        var bg_arrays = newArray()
        bg_arrays.set_len(int(mesh.ARRAY_MAX))
        bg_arrays[int(mesh.ARRAY_INDEX)]  = toVariant(self.bg_inds)
        bg_arrays[int(mesh.ARRAY_VERTEX)] = toVariant(self.bg_verts)
        bg_arrays[int(mesh.ARRAY_TEX_UV)] = toVariant(self.bg_uvs)
        bg_arrays[int(mesh.ARRAY_COLOR)]  = toVariant(self.bg_cols)

        var bg_m = gdnew[ArrayMesh]()
        bg_m.add_surface_from_arrays(mesh.PRIMITIVE_TRIANGLES, bg_arrays)
        self.bg_mesh_instance.mesh = bg_m