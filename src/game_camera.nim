import gdw
import godot, godotapi/[
        node_2d
    ]



gdobj GameCameraGDN of Node2D:
    var x*:int
    var y*:int
    var w*:int
    var h*:int

    var mx*:int
    var my*:int

    var min_x:int = -9999
    var min_y:int = -9999
    var max_x:int = 9999
    var max_y:int = 9999

    proc x2*():int {.gdExport.} = self.x + self.w
    proc y2*():int {.gdExport.} = self.y + self.h

    proc initialize*(x, y, w, h:int) {.gdExport.} =
        self.x = x
        self.y = y
        self.w = w
        self.h = h

    proc move*(tx, ty:int) {.gdExport.} =
        self.mx = max( self.min_x, min(tx - self.w div 2, self.max_x - self.w) )
        self.my = max( self.min_y, min(ty - self.h div 2, self.max_y - self.h) )

    proc to_cam_coords*(ox, oy:int):Vector2 {.gdExport.} =
        return vec2(
            ox - self.mx + self.x,
            oy - self.my + self.y
        )

    proc contains*(p:Vector2):bool {.gdExport.} =
        return int(p.x) >= self.x and int(p.y) >= self.y and
               int(p.x) < self.x2 and int(p.y) < self.y2

    proc set_limits*(min_x, min_y, max_x, max_y:int) {.used, gdExport.} =
        self.min_x = min_x
        self.min_y = min_y
        self.max_x = max_x
        self.max_y = max_y

