    proc drw_initialize() =
        self.name = "Terminal_GDN_Draw"
        print("(GDNative) - initializing terminal: ", self.name)
        self.drw_init_cells()

    proc drw_render() =
        self.update()

    # TODO: make tile objects (dicts)
    method draw*() =
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


