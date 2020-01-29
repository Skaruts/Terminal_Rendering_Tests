
# messy code -- I merged several terminal versions for quicker
# compile times and less hassle with inheritance in gd-nim


import random
import gdw
import godot
import godotapi/[
    godottypes,
    sprite,
    image,
    texture,
    canvas_item,
    resource_loader,
    image_texture,
    shader_material,
    mesh_instance_2d,
    mesh,
    array_mesh,
    visual_server,
    resource,
    node_2d
]

# type
#     TerminalKind = enum
#         Draw, Sprites, Shaders, Server, Mesh

const UVS = 1.0/16.0  # uv size
const DEF_FG* = col(0.75, 0.75, 0.75, 1)
const DEF_BG* = col(0, 0, 0, 1)

gdobj RLTerminal of Node2D:
    var GW*:int
    var GH*:int
    var CS*:int
    var fg*:Color = DEF_FG
    var bg*:Color = DEF_BG
    var font*:Texture
    # case kind:TerminalKind
    # of Draw:
    var drw_glyph_rects: seq[Rect2]
    var drw_cell_rects: seq[Rect2]
    var drw_cell_glyphs: seq[int]
    var drw_fg_colors: seq[Color]
    var drw_bg_colors: seq[Color]
    # of Sprites:
    var spr_fg_cells: seq[Sprite]
    var spr_bg_cells: seq[Sprite]
    # of Shaders:
    var shd_cells: seq[Sprite]
    # of Server:
    var srv_glyph_rects: seq[Rect2]
    var srv_cell_glyphs:seq[int]
    var srv_cell_rects: seq[Rect2]
    var srv_cell_fg_rids:seq[Rid]
    var srv_cell_bg_rids:seq[Rid]
    var srv_cell_fgs:seq[Color]
    var srv_cell_bgs:seq[Color]
    var srv_font_rid:RID
    # of Mesh:
    var msh_fg_mesh_instance:MeshInstance2D
    var msh_bg_mesh_instance:MeshInstance2D
    var msh_fg_verts:PoolVector2Array
    var msh_fg_uvs:PoolVector2Array
    var msh_fg_cols:PoolColorArray
    var msh_fg_inds:PoolIntArray
    var msh_bg_verts:PoolVector2Array
    var msh_bg_uvs:PoolVector2Array
    var msh_bg_cols:PoolColorArray
    var msh_bg_inds:PoolIntArray

    var kind:string

    # var proc_initialize:proc()
    # var proc_render:proc()
    # var proc_put:proc()
    # var proc_clear:proc()
    # var proc_init_cells:proc()


    ############################################################################

    #       Common terminal functions

    ############################################################################
    proc initialize*(kind:string, gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.GW = gw
        self.GH = gh
        self.CS = cs
        randomize()
        self.font = font
        self.kind = kind
        case self.kind
        of "draw":    self.drw_initialize()
        of "sprites": self.spr_initialize()
        of "shaders": self.shd_initialize()
        of "server":  self.srv_initialize()
        of "mesh":    self.msh_initialize()

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc render*() {.gdExport.} =
        case self.kind
        of "draw":    self.drw_render()
        of "sprites": self.spr_render()
        of "shaders": self.shd_render()
        of "server":  self.srv_render()
        of "mesh":    self.msh_render()

    proc put*(x, y, glyph:int) {.gdExport.} =
        case self.kind
        of "draw":    self.drw_put(x, y, glyph)
        of "sprites": self.spr_put(x, y, glyph)
        of "shaders": self.shd_put(x, y, glyph)
        of "server":  self.srv_put(x, y, glyph)
        of "mesh":    self.msh_put(x, y, glyph)

    proc clear*() {.gdExport.} =
        case self.kind
        of "draw":    self.drw_clear()
        of "sprites": self.spr_clear()
        of "shaders": self.shd_clear()
        of "server":  self.srv_clear()
        of "mesh":    self.msh_clear()

    # proc init_cells*() {.gdExport.} =
    #     self.proc_init_cells()



    ############################################################################

    #       Terminal using 2 grids of sprites (background and foreground)

    ############################################################################
    proc spr_initialize() =
        self.name = "Terminal_GDN_Sprites"
        print("(GDNative) - initializing terminal: ", self.name)
        self.spr_init_cells()

    proc spr_render() =
        discard

    proc spr_clear() =
        for i in 0..<self.GW*self.GH:
            self.spr_fg_cells[i].frame = 0
            self.spr_fg_cells[i].modulate = DEF_FG
            self.spr_bg_cells[i].modulate = DEF_BG

    proc spr_put(x, y, glyph:int) =
        let i = x+y*self.GW
        self.spr_fg_cells[i].frame = glyph
        self.spr_fg_cells[i].modulate = self.fg
        self.spr_bg_cells[i].modulate = self.bg

    proc spr_init_cells() =
        print("(GDNative) - initializing cells")

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let pos = vec2(float(i*self.CS), float(j*self.CS))

                # background
                var bg_cell = gdnew[Sprite]()
                self.add_child(bg_cell)
                self.spr_bg_cells.add(bg_cell)

                bg_cell.centered = false
                bg_cell.texture = self.font # as Texture
                bg_cell.vframes = 16
                bg_cell.hframes = 16
                bg_cell.frame = 219
                bg_cell.position = pos

                bg_cell.modulate = DEF_BG


                # foreground
                var fg_cell = gdnew[Sprite]()
                self.add_child(fg_cell)
                self.spr_fg_cells.add(fg_cell)

                fg_cell.centered = false
                fg_cell.texture = self.font # as Texture
                fg_cell.vframes = 16
                fg_cell.hframes = 16
                fg_cell.frame = 0
                fg_cell.position = pos

                fg_cell.modulate = DEF_FG




    ############################################################################

    #       Terminal using a draw functions

    ############################################################################
    proc drw_initialize() =
        self.name = "Terminal_GDN_Draw"
        print("(GDNative) - initializing terminal: ", self.name)
        self.drw_init_cells()

    proc drw_render() =
        self.update()

    # TODO: make tile objects (dicts)
    method draw*() =
        if self.kind == "draw":
            for i in 0..<self.GW*self.GH:
                self.draw_texture_rect_region( self.font, self.drw_cell_rects[i], self.drw_glyph_rects[219], self.drw_bg_colors[i] )
                self.draw_texture_rect_region( self.font, self.drw_cell_rects[i], self.drw_glyph_rects[self.drw_cell_glyphs[i]], self.drw_fg_colors[i] )

    proc drw_clear() =
        for i in 0..<self.GW*self.GH:
            self.drw_cell_glyphs[i] = 0
            self.drw_fg_colors[i] = DEF_FG
            self.drw_bg_colors[i] = DEF_BG

    proc drw_put(x, y, glyph:int) =
        let i = x+y*self.GW
        self.drw_cell_glyphs[i] = glyph
        self.drw_fg_colors[i] = self.fg
        self.drw_bg_colors[i] = self.bg


    proc drw_init_cells() =
        print("(GDNative) - initializing cells")

        for i in 0..<16*16: # tileset is 16x16 tiles wide/high
            self.drw_glyph_rects.add( rect2((i mod 16)*self.CS, (i div 16)*self.CS, self.CS, self.CS) )

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                self.drw_cell_rects.add( rect2(i*self.CS, j*self.CS, self.CS, self.CS) )
                self.drw_fg_colors.add( DEF_FG )
                self.drw_bg_colors.add( DEF_BG )
                self.drw_cell_glyphs.add( 0 )




    ############################################################################

    #       Terminal using MeshInstance2D's

    ############################################################################
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




    ############################################################################

    #       Terminal using the VisualServer directly (not working properly)

    ############################################################################
    proc srv_initialize() =
        self.name = "Terminal_GDN_Server"
        print("(GDNative) - initializing terminal: ", self.name)
        self.srv_font_rid = self.font.get_rid()
        self.srv_init_cells()

    proc srv_render() =
        for i in 0..<self.GW*self.GH:
            let fg_cell_rid = self.srv_cell_fg_rids[i]
            let bg_cell_rid = self.srv_cell_bg_rids[i]

            visualserver.canvas_item_clear(bg_cell_rid)
            visualserver.canvas_item_clear(fg_cell_rid)

            visualserver.canvas_item_add_texture_rect_region(
                bg_cell_rid, self.srv_cell_rects[i], self.srv_font_rid,
                self.srv_glyph_rects[219], self.srv_cell_bgs[i]
            )
            visualserver.canvas_item_add_texture_rect_region(
                fg_cell_rid, self.srv_cell_rects[i], self.srv_font_rid,
                self.srv_glyph_rects[self.srv_cell_glyphs[i]], self.srv_cell_fgs[i]
            )

    proc srv_clear() =
        for i in 0..<self.GW*self.GH:
            self.srv_cell_glyphs[i] = 0
            self.srv_cell_fgs[i] = DEF_FG
            self.srv_cell_bgs[i] = DEF_BG

    proc srv_put*(x, y, glyph:int) {.gdExport.} =
        let i = x+y*self.GW
        self.srv_cell_glyphs[i] = glyph
        self.srv_cell_fgs[i] = self.fg
        self.srv_cell_bgs[i] = self.bg

    proc srv_init_cells() =
        # print("(GDNative) - initializing cells: ", self.name)
        # for j in 0..<self.GH:
        #     for i in 0..<self.GW:
        #         self.srv_glyph_rects.add( rect2(i*self.CS, j*self.CS, self.CS, self.CS) )

        for i in 0..<16*16: # tileset is 16x16 tiles wide/high
            self.srv_glyph_rects.add( rect2((i mod 16)*self.CS, (i div 16)*self.CS, self.CS, self.CS) )

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let glyph = 64
                let bg = DEF_BG
                let fg = DEF_FG

                let rect = rect2(i*self.CS, j*self.CS, self.CS, self.CS)
                let bg_cell_rid = visual_server.canvas_item_create()
                let fg_cell_rid = visual_server.canvas_item_create()

                self.srv_cell_glyphs.add(glyph)
                self.srv_cell_bgs.add(bg)
                self.srv_cell_fgs.add(fg)
                self.srv_cell_rects.add( rect )
                self.srv_cell_bg_rids.add( bg_cell_rid )
                self.srv_cell_fg_rids.add( fg_cell_rid )

                visual_server.canvas_item_set_parent(bg_cell_rid, self.get_canvas_item())
                visual_server.canvas_item_set_parent(fg_cell_rid, self.get_canvas_item())
                visual_server.canvas_item_add_texture_rect_region(bg_cell_rid, rect, self.srv_font_rid, self.srv_glyph_rects[219], bg)
                visual_server.canvas_item_add_texture_rect_region(fg_cell_rid, rect, self.srv_font_rid, self.srv_glyph_rects[glyph], fg)





    ############################################################################

    #       Terminal using 1 grid of sprites with shaders

    ############################################################################
    proc shd_initialize() =
        self.name = "Terminal_GDN_Shaders"
        print("(GDNative) - initializing terminal: ", self.name)
        self.shd_init_cells()

    proc shd_render() =
        discard

    proc shd_clear() =
        for i in 0..<self.GW*self.GH:
            self.shd_cells[i].frame = 0
            self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(DEF_FG))
            self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(DEF_BG))

    proc shd_put(x, y, glyph:int) =
        let i = x+y*self.GW
        self.shd_cells[i].frame = glyph
        self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(self.fg))
        self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(self.bg))

    proc shd_init_cells() =
        print("(GDNative) - initializing cells")
        let shader = load("res://resources/cell_shader.shader") as Shader

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                var cell = gdnew[Sprite]()
                self.add_child(cell)
                self.shd_cells.add(cell)

                cell.centered = false
                cell.texture = self.font
                cell.vframes = 16
                cell.hframes = 16
                cell.frame = 0
                cell.position = vec2(float(i*self.CS), float(j*self.CS))

                cell.material = gdnew[ShaderMaterial]() #as ShaderMaterial
                cell.material.as(ShaderMaterial).shader = shader
                self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(DEF_FG))
                self.shd_cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(DEF_BG))














