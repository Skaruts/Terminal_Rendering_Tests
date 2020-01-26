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

