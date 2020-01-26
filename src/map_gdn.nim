import random, times, strutils
# import nimex   # <-- xrange, etc
import godot, godotapi/[node_2d]
import gdw, game_camera, terminal

template benchmark(benchmarkName: string, code: untyped) =
    block:
        let t0 = epochTime()
        code
        let elapsed = epochTime() - t0
        let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
        echo "    CPU Time: ", elapsedStr, "s\n"


const FLOOR = 0
const WALL = 1
const wall_color = col("717c8a")
const floor_color = col("3f4956")

gdobj MapGDN of Node2D:
    var w:int
    var h:int
    var tilemap:seq[int]

    proc initialize*(w, h:int) {.gdExport.} =
        self.w = w
        self.h = h

        self.tilemap = newSeq[int](w*h)

        for j in 0..<h:
            for i in 0..<w:
                if i == 0 or j == 0 or i == w-1 or j == h-1 or rand(0..100) > 97:
                    self.tilemap[i+j*w] = WALL

    proc can_move*(x, y:int):bool {.gdExport.} =
        return self.tilemap[x+y*self.w] != WALL

    proc update_stuff*(terminal:Terminal, cam:GameCameraGDN) {.gdExport.} =
        benchmark "":
            for j in 0..<cam.h:
                for i in 0..<cam.w:
                    let mx = cam.mx + i
                    let my = cam.my + j

                    if mx >= 0 and my >= 0 and mx < self.w and my < self.h:
                        let p = cam.to_cam_coords(mx, my)

                        if cam.contains(p):
                            if self.tilemap[mx+my*self.w] == WALL:
                                terminal.set_fg(wall_color)
                                terminal.put(int(p.x), int(p.y), 35)
                            else:
                                terminal.set_fg(floor_color)
                                terminal.put(int(p.x), int(p.y), 249)




