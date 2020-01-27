import random
import gdw
import godot
import godotapi/[
    godottypes,
    sprite,
    texture,
    # canvas_item,
    resource_loader,
    shader_material,
    # resource,
    node_2d
]

const DEF_FG = col(0.75, 0.75, 0.75, 1)
const DEF_BG = col(0, 0, 0, 1)

gdobj Terminal_GDN_Shaders of Node2D:
    var GW:int
    var GH:int
    var CS:int
    var fg:Color = DEF_FG
    var bg:Color = DEF_BG
    var font:Texture

    var cells: seq[Sprite]


    proc initialize*(gw, gh, cs:int, font:Texture) {.gdExport.} =
        self.name = "Terminal_GDN_Shaders"
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
            self.cells[i].frame = 0
            self.cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(DEF_FG))
            self.cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(DEF_BG))

    proc set_fg*(fg:Color) {.gdExport.} = self.fg = fg
    proc set_bg*(fg:Color) {.gdExport.} = self.fg = fg

    proc put*(x, y, glyph:int) {.gdExport.} =
        let i = x+y*self.GW
        self.cells[i].frame = glyph
        self.cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(self.fg))
        self.cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(self.bg))

    proc init_cells() =
        print("(GDNative) - initializing cells")
        let shader = load("res://resources/cell_shader.shader") as Shader

        for j in 0..<self.GH:
            for i in 0..<self.GW:
                var cell = gdnew[Sprite]()
                self.add_child(cell)
                self.cells.add(cell)

                cell.centered = false
                cell.texture = self.font
                cell.vframes = 16
                cell.hframes = 16
                cell.frame = 0
                cell.position = vec2(float(i*self.CS), float(j*self.CS))

                cell.material = gdnew[ShaderMaterial]() #as ShaderMaterial
                cell.material.as(ShaderMaterial).shader = shader
                self.cells[i].material.as(ShaderMaterial).setShaderParam("fg", toVariant(DEF_FG))
                self.cells[i].material.as(ShaderMaterial).setShaderParam("bg", toVariant(DEF_BG))

