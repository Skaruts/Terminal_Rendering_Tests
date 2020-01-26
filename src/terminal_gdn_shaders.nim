
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

