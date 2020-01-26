    proc msh_initialize() =
        self.name = "Terminal_GDN_Mesh"
        print("(GDNative) - initializing terminal: ", self.name)
        self.msh_init_cells()

    proc msh_render() =
        self.msh_update_mesh()

    proc msh_clear*() {.gdExport.} =
        for j in 0..<self.GH:
            for i in 0..<self.GW:
                self.fg = DEF_FG
                self.bg = DEF_BG
                self.put(i, j, 0)

    proc msh_put*(x, y, glyph:int) =
        if x >= 0 and y >= 0 and x < self.GW and y < self.GH:
            let i = (x+y*self.GW)*4
            let u = float(glyph mod 16) * UVS
            let v = float(glyph div 16) * UVS
            var u2 = u + UVS
            var v2 = v + UVS

            self.msh_fg_uvs[i+0] = vec2(  u,  v )
            self.msh_fg_uvs[i+1] = vec2( u2,  v )
            self.msh_fg_uvs[i+2] = vec2( u2, v2 )
            self.msh_fg_uvs[i+3] = vec2(  u, v2 )

            self.msh_fg_cols[i+0] = self.fg
            self.msh_fg_cols[i+1] = self.fg
            self.msh_fg_cols[i+2] = self.fg
            self.msh_fg_cols[i+3] = self.fg

            self.msh_bg_cols[i+0] = self.bg
            self.msh_bg_cols[i+1] = self.bg
            self.msh_bg_cols[i+2] = self.bg
            self.msh_bg_cols[i+3] = self.bg


    proc msh_init_cells() =
        print("(GDN) - initializing cells")
        self.msh_fg_verts = newPoolVector2Array()
        self.msh_fg_uvs   = newPoolVector2Array()
        self.msh_fg_cols  = newPoolColorArray()
        self.msh_fg_inds  = newPoolIntArray()
        self.msh_bg_verts = newPoolVector2Array()
        self.msh_bg_uvs   = newPoolVector2Array()
        self.msh_bg_cols  = newPoolColorArray()
        self.msh_bg_inds  = newPoolIntArray()

        self.msh_bg_mesh_instance = gdnew[MeshInstance2D]()
        self.msh_bg_mesh_instance.name = "bg_mesh_instance"
        self.msh_bg_mesh_instance.texture = self.font
        self.add_child(self.msh_bg_mesh_instance)

        self.msh_fg_mesh_instance = gdnew[MeshInstance2D]()
        self.msh_fg_mesh_instance.name = "fg_mesh_instance"
        self.msh_fg_mesh_instance.texture = self.font
        self.add_child(self.msh_fg_mesh_instance)

        var idx = 0
        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let a = vec2(  i    * self.CS,  j    * self.CS )
                let b = vec2( (i+1) * self.CS,  j    * self.CS )
                let c = vec2( (i+1) * self.CS, (j+1) * self.CS )
                let d = vec2(  i    * self.CS, (j+1) * self.CS )

                self.msh_add_fg_quad(idx, a, b, c, d, 64, DEF_FG)
                self.msh_add_bg_quad(idx, a, b, c, d, 219, DEF_FG)

                idx += 4
        self.msh_update_mesh()

    proc msh_add_fg_quad(i:int, a, b, c, d:Vector2, glyph:int, color:Color) =
        let u = float(glyph mod 16)*UVS
        let v = float(glyph div 16)*UVS
        let u2 = u + UVS
        let v2 = v + UVS

        let ua = vec2(  u,  v )
        let ub = vec2( u2,  v )
        let uc = vec2( u2, v2 )
        let ud = vec2(  u, v2 )

        self.msh_add_fg_vert(a, ua, color)
        self.msh_add_fg_vert(b, ub, color)
        self.msh_add_fg_vert(c, uc, color)
        self.msh_add_fg_vert(d, ud, color)

        for idx in [i+0, i+1, i+2, i+0, i+2, i+3]:
            self.msh_fg_inds.add(cint(idx))

    proc msh_add_bg_quad(i:int, a, b, c, d:Vector2, glyph:int, color:Color) =
        let u = float(glyph mod 16)*UVS
        let v = float(glyph div 16)*UVS
        let u2 = u + UVS
        let v2 = v + UVS

        let ua = vec2(  u,  v )
        let ub = vec2( u2,  v )
        let uc = vec2( u2, v2 )
        let ud = vec2(  u, v2 )

        self.msh_add_bg_vert(a, ua, color)
        self.msh_add_bg_vert(b, ub, color)
        self.msh_add_bg_vert(c, uc, color)
        self.msh_add_bg_vert(d, ud, color)

        for idx in [i+0, i+1, i+2, i+0, i+2, i+3]:
            self.msh_bg_inds.add(cint(idx))

    proc msh_add_fg_vert(v, uv:Vector2, c:Color) =
        self.msh_fg_verts.add(v)
        self.msh_fg_uvs.add(uv)
        self.msh_fg_cols.add(c)

    proc msh_add_bg_vert(v, uv:Vector2, c:Color) =
        self.msh_bg_verts.add(v)
        self.msh_bg_uvs.add(uv)
        self.msh_bg_cols.add(c)


    proc msh_update_mesh() =
        var fg_arrays = newArray()
        fg_arrays.set_len(int(mesh.ARRAY_MAX))
        fg_arrays[int(mesh.ARRAY_INDEX)]  = toVariant(self.msh_fg_inds)
        fg_arrays[int(mesh.ARRAY_VERTEX)] = toVariant(self.msh_fg_verts)
        fg_arrays[int(mesh.ARRAY_TEX_UV)] = toVariant(self.msh_fg_uvs)
        fg_arrays[int(mesh.ARRAY_COLOR)]  = toVariant(self.msh_fg_cols)

        var fg_m = gdnew[ArrayMesh]()
        fg_m.add_surface_from_arrays(mesh.PRIMITIVE_TRIANGLES, fg_arrays)
        self.msh_fg_mesh_instance.mesh = fg_m


        var bg_arrays = newArray()
        bg_arrays.set_len(int(mesh.ARRAY_MAX))
        bg_arrays[int(mesh.ARRAY_INDEX)]  = toVariant(self.msh_bg_inds)
        bg_arrays[int(mesh.ARRAY_VERTEX)] = toVariant(self.msh_bg_verts)
        bg_arrays[int(mesh.ARRAY_TEX_UV)] = toVariant(self.msh_bg_uvs)
        bg_arrays[int(mesh.ARRAY_COLOR)]  = toVariant(self.msh_bg_cols)

        var bg_m = gdnew[ArrayMesh]()
        bg_m.add_surface_from_arrays(mesh.PRIMITIVE_TRIANGLES, bg_arrays)
        self.msh_bg_mesh_instance.mesh = bg_m