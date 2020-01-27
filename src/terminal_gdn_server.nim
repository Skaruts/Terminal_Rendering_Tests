import random
import gdw
import godot
import godotapi/[
    godottypes,
    texture,
    # canvas_item,
    visual_server,
    # resource,
    node_2d
]

const DEF_FG = col(0.75, 0.75, 0.75, 1)
const DEF_BG = col(0, 0, 0, 1)

gdobj Terminal_GDN_Server of Node2D:
    var GW:int
    var GH:int
    var CS:int
    var fg:Color = DEF_FG
    var bg:Color = DEF_BG
    var font:Texture
    var font_rid:RID

    var glyph_rects: seq[Rect2]
    var cell_glyphs:seq[int]
    var cell_rects: seq[Rect2]
    var cell_fg_rids:seq[Rid]
    var cell_bg_rids:seq[Rid]
    var cell_fgs:seq[Color]
    var cell_bgs:seq[Color]


    proc initialize*(gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.name = "Terminal_GDN_Server"
        print("(GDNative) - initializing terminal: ", self.name)
        randomize()
        self.GW = gw
        self.GH = gh
        self.CS = cs
        self.font = font
        self.font_rid = self.font.get_rid()

        self.init_cells()

    proc render*() {.gdExport.} =
        for i in 0..<self.GW*self.GH:
            let fg_cell_rid = self.cell_fg_rids[i]
            let bg_cell_rid = self.cell_bg_rids[i]

            visualserver.canvas_item_clear(bg_cell_rid)
            visualserver.canvas_item_clear(fg_cell_rid)

            visualserver.canvas_item_add_texture_rect_region(
                bg_cell_rid, self.cell_rects[i], self.font_rid,
                self.glyph_rects[219], self.cell_bgs[i]
            )
            visualserver.canvas_item_add_texture_rect_region(
                fg_cell_rid, self.cell_rects[i], self.font_rid,
                self.glyph_rects[self.cell_glyphs[i]], self.cell_fgs[i]
            )

    proc clear*() {.gdExport.} =
        for i in 0..<self.GW*self.GH:
            self.cell_glyphs[i] = 0
            self.cell_fgs[i] = DEF_FG
            self.cell_bgs[i] = DEF_BG

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc put*(x, y, glyph:int) {.gdExport.} =
        let i = x+y*self.GW
        self.cell_glyphs[i] = glyph
        self.cell_fgs[i] = self.fg
        self.cell_bgs[i] = self.bg

    proc init_cells() =
        # print("(GDNative) - initializing cells: ", self.name)
        # for j in 0..<self.GH:
        #     for i in 0..<self.GW:
        #         self.glyph_rects.add( rect2(i*self.CS, j*self.CS, self.CS, self.CS) )

        for i in 0..<16*16: # tileset is 16x16 tiles wide/high
            self.glyph_rects.add( rect2((i mod 16)*self.CS, (i div 16)*self.CS, self.CS, self.CS) )

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                let glyph = 64
                let bg = DEF_BG
                let fg = DEF_FG

                let rect = rect2(i*self.CS, j*self.CS, self.CS, self.CS)
                let bg_cell_rid = visual_server.canvas_item_create()
                let fg_cell_rid = visual_server.canvas_item_create()

                self.cell_glyphs.add(glyph)
                self.cell_bgs.add(bg)
                self.cell_fgs.add(fg)
                self.cell_rects.add( rect )
                self.cell_bg_rids.add( bg_cell_rid )
                self.cell_fg_rids.add( fg_cell_rid )

                visual_server.canvas_item_set_parent(bg_cell_rid, self.get_canvas_item())
                visual_server.canvas_item_set_parent(fg_cell_rid, self.get_canvas_item())
                visual_server.canvas_item_add_texture_rect_region(bg_cell_rid, rect, self.font_rid, self.glyph_rects[219], bg)
                visual_server.canvas_item_add_texture_rect_region(fg_cell_rid, rect, self.font_rid, self.glyph_rects[glyph], fg)

