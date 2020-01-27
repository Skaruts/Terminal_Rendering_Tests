import random
import gdw
import godot
import godotapi/[
    texture,
    node_2d
]

const DEF_FG = col(0.75, 0.75, 0.75, 1)
const DEF_BG = col(0, 0, 0, 1)

gdobj Terminal_GDN_Draw of Node2D:
    var GW:int
    var GH:int
    var CS:int
    var fg:Color = DEF_FG
    var bg:Color = DEF_BG
    var font:Texture

    var glyph_rects: seq[Rect2]
    var cell_rects: seq[Rect2]
    var cell_glyphs: seq[int]
    var fg_colors: seq[Color]
    var bg_colors: seq[Color]


    proc initialize*(gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.name = "Terminal_GDN_Draw"
        print("(GDNative) - initializing terminal: ", self.name)
        randomize()
        self.GW = gw
        self.GH = gh
        self.CS = cs
        self.font = font

        self.init_cells()

    proc render*() {.gdExport.} =
        self.update()

    # TODO: make tile objects (dicts)
    method draw*() =
        for i in 0..<self.GW*self.GH:
            self.draw_texture_rect_region( self.font, self.cell_rects[i], self.glyph_rects[219], self.bg_colors[i] )
            self.draw_texture_rect_region( self.font, self.cell_rects[i], self.glyph_rects[self.cell_glyphs[i]], self.fg_colors[i] )

    proc clear*() {.gdExport.} =
        for i in 0..<self.GW*self.GH:
            self.cell_glyphs[i] = 0
            self.fg_colors[i] = DEF_FG
            self.bg_colors[i] = DEF_BG

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc put*(x, y, glyph:int) {.gdExport.} =
        let i = x+y*self.GW
        self.cell_glyphs[i] = glyph
        self.fg_colors[i] = self.fg
        self.bg_colors[i] = self.bg


    proc init_cells() =
        print("(GDNative) - initializing cells")

        for i in 0..<16*16: # tileset is 16x16 tiles wide/high
            self.glyph_rects.add( rect2((i mod 16)*self.CS, (i div 16)*self.CS, self.CS, self.CS) )

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                self.cell_rects.add( rect2(i*self.CS, j*self.CS, self.CS, self.CS) )
                self.fg_colors.add( DEF_FG )
                self.bg_colors.add( DEF_BG )
                self.cell_glyphs.add( 0 )


