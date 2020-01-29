import random
import gdw
import godot, godotapi/[
    # color,
    node,
    godottypes,
    scene_tree,
    resource_loader,
    global_constants,
    packed_scene,
    input_event_mouse_button,
    objects,
    node_2d
]
import
    rl_camera,
    fov,
    # data,
    rl_terminal

# import times
# import strutils
# template benchmark(benchmarkName: string, code: untyped) =
#     block:
#         let t0 = epochTime()
#         code
#         let elapsed = epochTime() - t0
#         let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
#         echo "    CPU Time: ", elapsedStr, "s\n"


const FLOOR {.used.} = 0
const WALL = 1
const wall_color = col("717c8a")
const floor_color = col("3f4956")

type
    Tile = ref object
        fg:Color
        glyph:int
        discovered:bool

proc new_tile(glyph=0, fg = wall_color):Tile =
    new result
    result.glyph = glyph
    result.fg = fg
    result.discovered = false


gdobj RLBaseMap of Node2D:
    var w:int
    var h:int
    var tilemap:seq[int]
    var tiles:seq[Tile]
    var fov:Fov

    proc initialize*(w, h:int) {.gdExport.} =
        self.w = w
        self.h = h

        self.fov = gdnew[Fov]()
        self.fov.init(w, h)

        self.tilemap = newSeq[int](w*h)

        for j in 0..<h:
            for i in 0..<w:
                if i == 0 or j == 0 or i == w-1 or j == h-1 or rand(0..100) > 97:
                    self.tilemap[i+j*w] = WALL
                    self.tiles.add(new_tile(35, wall_color))
                    self.fov.set_cell(i, j, false, true, true)
                else:
                    self.tiles.add(new_tile(249, floor_color))
                    self.fov.set_cell(i, j, false, false, false)


    # method ready*() =
    #     print("------------  MAP INITIALIZE TEST   ----------")

    #     # print(self.get_tree().root)

    #     # let data = load("res://scripts/autoload/Data.gd") as Node
    #     # print(data.fov_radius)
    #     # print(data.get("fov_radius"))
    #     let data = self.get_tree().root.get_node("data")# as Node
    #     # print("fov_radius: ", data.fov_radius) # Compile error: undeclared field: 'fov_radius' for type godottypes.Node
    #     print("fov_radius: ", data.get("fov_radius")) # runtime error: Unhandled Nim exception (NilAccessError): Could not access value because it is nil.



    #     # resource_loader.singleton.load("res://scripts/autoload/Data.gd")

    #     # print("data class: ", data.get_class())
    #     # print("data list: ", data.getPropertyListImpl())

    #     print("---------------------------------------------")

    proc can_move*(x, y:int):bool {.gdExport.} =
        return self.tilemap[x+y*self.w] != WALL

    # proc draw_tile(x, y:int) =
    #     if self.tilemap[mx+my*self.w] == WALL:
    #         terminal.set_fg(wall_color)
    #         terminal.put(int(p.x), int(p.y), 35)
    #     else:
    #         terminal.set_fg(floor_color)
    #         terminal.put(int(p.x), int(p.y), 249)

    proc update_tiles(terminal:RLTerminal, cam:RLCamera) =
        # benchmark "":
        for j in 0..<cam.h:
            for i in 0..<cam.w:
                let mx = cam.mx + i
                let my = cam.my + j

                if mx >= 0 and my >= 0 and mx < self.w and my < self.h:
                    let p = cam.to_cam_coords(mx, my)
                    if cam.contains(p):
                        let tile = self.tiles[mx+my*self.w]
                        let visible = self.fov.is_visible(mx, my)

                        if visible and not tile.discovered:
                            tile.discovered = true

                        if tile.discovered:
                            if visible: terminal.set_fg(tile.fg)
                            else:       terminal.set_fg(tile.fg.darkened(0.65))

                            terminal.put(int(p.x), int(p.y), tile.glyph)


    proc recompute_fov*(player_pos:Vector2, fov_radius:int) {.gdExport.}  =
        self.fov.recompute(player_pos.x.int, player_pos.y.int, fov_radius, true)

    proc update_stuff*(terminal:RLTerminal, cam:RLCamera) {.gdExport.} =
        self.update_tiles(terminal, cam)
