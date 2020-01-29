import gdw
import godot, godotapi/[
        node
    ]


gdobj Data of Node:
    var DEF_FG* {.gdExport.} = col(0.75,0.75,0.75,1)
    var DEF_BG* {.gdExport.} = col(0,0,0,1)
    var font_path* = "res://assets/cp437_20x20.png"
    #var font_path = "res://assets/font1_24x24_a.png"

    var GW* {.gdExport.} = 80    # grid width
    var GH* {.gdExport.} = 50    # grid height
    var CS*   {.gdExport.} = 20    # cell size

    var show_debug_info* {.gdExport.}  = true

    var took_turn* {.gdExport.}        = true

    var key_repeat* {.gdExport.}       = true      # if false, you move once per key press
    var key_cooldown* {.gdExport.}     = 0.05
    var key_1st_cooldown* {.gdExport.} = 0.250
    var key_timer* {.gdExport.}        = 0.0
    var max_key_timer* {.gdExport.}    = 0.0 #self.key_1st_cooldown

    var fov_radius* {.gdExport.}       = 42

    method init*() =
        self.max_key_timer = self.key_1st_cooldown