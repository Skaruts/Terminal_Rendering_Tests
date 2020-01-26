
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

