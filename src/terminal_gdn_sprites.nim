import random
import gdw
import godot
import godotapi/[
    godottypes,
    sprite,
    texture,
    # canvas_item,
    node_2d
]

const DEF_FG = col(0.75, 0.75, 0.75, 1)
const DEF_BG = col(0, 0, 0, 1)

gdobj Terminal_GDN_Mesh of Node2D:
    var GW:int
    var GH:int
    var CS:int
    var fg:Color = DEF_FG
    var bg:Color = DEF_BG
    var font:Texture

    var fg_mesh_instance:MeshInstance2D
    var bg_mesh_instance:MeshInstance2D
    var fg_verts:PoolVector2Array
    var fg_uvs:PoolVector2Array
    var fg_cols:PoolColorArray
    var fg_inds:PoolIntArray
    var bg_verts:PoolVector2Array
    var bg_uvs:PoolVector2Array
    var bg_cols:PoolColorArray
    var bg_inds:PoolIntArray


    proc initialize*(gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.name = "Terminal_GDN_Sprites"
        print("(GDNative) - initializing terminal: ", self.name)
        randomize()
        self.GW = gw
        self.GH = gh
        self.CS = cs
        self.font = font

        self.init_cells()

    proc render*() {.gdExport.} =
        discard

    proc clear*() {.gdExport.} =
        for i in 0..<self.GW*self.GH:
            self.fg_cells[i].frame = 0
            self.fg_cells[i].modulate = DEF_FG
            self.bg_cells[i].modulate = DEF_BG

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc put*(x, y, glyph:int) {.gdExport.} =
        let i = x+y*self.GW
        self.fg_cells[i].frame = glyph
        self.fg_cells[i].modulate = self.fg
        self.bg_cells[i].modulate = self.bg

    proc init_cells() =
        print("(GDNative) - initializing cells")

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let pos = vec2(float(i*self.CS), float(j*self.CS))

                # background
                var bg_cell = gdnew[Sprite]()
                self.add_child(bg_cell)
                self.bg_cells.add(bg_cell)

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
                self.fg_cells.add(fg_cell)

                fg_cell.centered = false
                fg_cell.texture = self.font # as Texture
                fg_cell.vframes = 16
                fg_cell.hframes = 16
                fg_cell.frame = 0
                fg_cell.position = pos

                fg_cell.modulate = DEF_FG

