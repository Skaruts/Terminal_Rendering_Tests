extends Node2D
# Autoloaded Script

var line_color = Color('FFFFFF')#Color(0, 0.7, 1, 0.3)
var vars = {}
var lines = []
var is_active = data.show_debug_info

var LAYER 		= CanvasLayer.new()
var ROOT 		= Control.new()
var label		= Label.new()

func _ready():
	z_index = 100
	setup_labels()

	ROOT.visible = is_active

func setup_labels():
	add_child(LAYER)
	LAYER.set_layer( 10 )
	LAYER.add_child(ROOT)
	ROOT.add_child(label)

	# label.add_font_override(label.get_name(), load("res://data/AR_24.tres"))
	# label.add_color_override("", Color("f5c538"))

#func _process(delta):
#	monitor("fps", OS.frames)


# monitors variables in real time
# call this function inside _process() to update the monitoring
func monitor(key, val, pad_size=-1):
	vars[key] = val

	var text = ""
	for k in vars:
		if pad_size >= 0:
			if typeof(vars[k]) == TYPE_REAL:
				vars[k] = str(vars[k]).pad_decimals(pad_size)
			elif typeof(vars[k]) == TYPE_VECTOR2:
				vars[k] = str( "(" + str(vars[k].x).pad_decimals(pad_size) + "," + str(vars[k].y).pad_decimals(pad_size)+ ")" )
		text += k + ": " + str(vars[k]) + "\n"

	label.text = text

func toggle_debug():
	print("----------- TOGGLE DEBUG -------------")
	is_active = not is_active
	ROOT.visible = is_active
#	update()

func _input(event):
#	if event.is_action_pressed("fast_quit"):			data.exit()
	if event.is_action_pressed("toggle_debug"):		toggle_debug()

#func draw_rect(pos, size, thickness):
#	if is_active:
#		var TW = data.TW
#		var TH = data.TH
#		var x2 = pos.x+size.x
#		var y2 = pos.y+size.y
#
#		lines.append( [Vector2(pos.x,  pos.y),   Vector2(x2   , pos.y), line_color, thickness] )
#		lines.append( [Vector2(x2   ,  pos.y),   Vector2(x2   ,    y2), line_color, thickness] )
#		lines.append( [Vector2(x2   ,     y2),   Vector2(pos.x,    y2), line_color, thickness] )
#		lines.append( [Vector2(pos.x,     y2),   Vector2(pos.x, pos.y), line_color, thickness] )
#
#		update()
#
#func _draw():
#	for l in lines:
#		draw_line( l[0], l[1], l[2], l[3] )
#
#	lines.clear()
