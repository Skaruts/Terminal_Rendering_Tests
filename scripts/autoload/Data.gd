extends Node

const DEF_FG = Color(0.75,0.75,0.75,1)
const DEF_BG = Color(0,0,0,1)

const font_path = "res://assets/cp437_20x20.png"
#const font_path = "res://assets/font1_24x24_a.png"
var GW = 80    # grid width
var GH = 50    # grid height
var CS = 20    # cell size

var show_debug_info = true

var took_turn             := true

var key_repeat            := true      # if false, you move once per key press
var key_cooldown          := 0.05
var key_1st_cooldown      := 0.250
var key_timer             := 0.0
var max_key_timer         := key_1st_cooldown


export var fov_radius = 42


