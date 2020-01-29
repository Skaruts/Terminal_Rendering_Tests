extends Node2D

enum { GDS, GDN }
enum {
	DRAW,
	SPRITES,
	SHADERS,
	SERVER, # not working properly
	MESH, # best so far
}
var mode = MESH
var code = GDN

var terminal
var cam
var map
var font

var dir             = Vector2()
var moving_left     = false # movement flags for no-key-repeat
var moving_right    = false
var moving_up       = false
var moving_down     = false
var moving          = false

var player =  {
	x = 10,
	y = 10,
	glyph = 64,
	fg = Color(1, 0.6, 0, 1)
}


func _ready():
	print(get_tree())
#	print(get_tree().get_root().get_node("data").get("fov_radius"))
	set_screen_layout()
	OS.vsync_enabled = false

	$Label.free()

	var img = load(data.font_path).get_data()
	img = utils.transparentationalisize_image(img) # <- make transparent
	var font = ImageTexture.new()
	font.create_from_image(img)

	match code:
		GDS:
			match mode:
				DRAW:    terminal = load("res://scripts/Terminal_Draw.gd").new(data.GW, data.GH, data.CS, font)
				SPRITES: terminal = load("res://scripts/Terminal_Sprites.gd").new(data.GW, data.GH, data.CS, font)
				SHADERS: terminal = load("res://scripts/Terminal_Shaders.gd").new(data.GW, data.GH, data.CS, font)
#				SERVER:  terminal = load("res://scripts/Terminal_Server.gd").new(data.GW, data.GH, data.CS, font)
				MESH:    terminal = load("res://scripts/Terminal_Mesh.gd").new(data.GW, data.GH, data.CS, font)
				_: assert(false, "invalid mode")
		GDN:
			terminal = load("res://scripts/gdnative/RLTerminal.gdns").new()
			match mode:
				DRAW:    terminal.initialize("draw", data.GW, data.GH, data.CS, font)
				SPRITES: terminal.initialize("sprites", data.GW, data.GH, data.CS, font)
				SHADERS: terminal.initialize("shaders", data.GW, data.GH, data.CS, font)
#				SERVER:  terminal.initialize("server", data.GW, data.GH, data.CS, font)
				MESH:    terminal.initialize("mesh", data.GW, data.GH, data.CS, font)
				_: assert(false, "invalid mode")

	add_child(terminal, true)

	map = Map.new()
	map.initialize(200, 200)
	add_child(map)
	cam = RLCamera.new()
	cam.initialize(0, 0, data.GW, data.GH)

	OS.set_window_title( "Simple Cell Rendering Test - " + terminal.name )





func _input(event):
	if event.is_action_pressed("quit"): # Q / Esc
		get_tree().quit()


	elif event.is_action_pressed("vsync"): # F4
		OS.vsync_enabled = not OS.vsync_enabled
		print("vsync:", OS.vsync_enabled)


func _process(delta):
	var took_turn = false

	cam.move(player.x, player.y)
	if data.took_turn:
		terminal.clear()

		map.update_stuff(terminal, cam, Vector2(player.x, player.y))

		var p = cam.to_cam_coords(player.x, player.y)
		terminal.set_fg(player.fg)
#		terminal.set_bg(Color(0,1,0,1))
		terminal.put(p.x, p.y, player.glyph)

		terminal.render()

	dir = Vector2()
	if Input.is_action_pressed("move_left"):  dir.x -= 1
	if Input.is_action_pressed("move_right"): dir.x += 1
	if Input.is_action_pressed("move_up"):    dir.y -= 1
	if Input.is_action_pressed("move_down"):  dir.y += 1

	if data.key_repeat:  data.took_turn = move_repeat(delta)
	else:                data.took_turn = move_once()



func try_move(dx:int, dy:int) -> bool:
#	print(dx, dy)
	if map.can_move(player.x+dx, player.y+dy):
		player.x += dx
		player.y += dy
		return true
	return false

func move_repeat(delta) -> bool:
	var took_turn = false

	# if already moving since last frame, make the cooldown shorter
	# else, make it longer for the first key press
	if moving:  data.max_key_timer = data.key_cooldown
	else:       data.max_key_timer = data.key_1st_cooldown

	# check if any movement key is being pressed
	moving = dir != Vector2()

	# if none is pressed, reset the timer so the player is free to try_move
	if not moving: data.key_timer = 0.0

	# if no cooldown and a key was pressed
	if data.key_timer <= 0 and moving:
		if try_move(dir.x, dir.y): took_turn = true
		elif try_move(0, dir.y):   took_turn = true
		elif try_move(dir.x, 0):   took_turn = true

		if took_turn:
			data.key_timer = data.max_key_timer   # set the cooldown

	# else if still cooling down, just reduce timer by delta
	else:
		data.key_timer -= delta

#	print(data.key_timer, ", ", moving)
	return took_turn

func move_once() -> bool:
	# TODO: make this movement code slide on walls and able to use
	#       diagonals with two keys
	var took_turn = false

	if dir.x < 0 and not moving_left:
		took_turn = try_move( -1, 0 )
		moving_left = true
	elif not dir.x < 0 and moving_left:
		moving_left = false

	if dir.x > 0 and not moving_right:
		took_turn = try_move( 1, 0 )
		moving_right = true
	elif not dir.x > 0 and moving_right:
		moving_right = false

	if dir.y < 0 and not moving_up:
		took_turn = try_move( 0, -1 )
		moving_up = true
	elif not dir.y < 0 and moving_up:
		moving_up = false

	if dir.y > 0 and not moving_down:
		took_turn = try_move( 0, 1 )
		moving_down = true
	elif not dir.y > 0 and moving_down:
		moving_down = false

	return took_turn

#var debug_label = get_node("DebugLabel")
#func add_debug_text(text):
#	debug_label.text = debug_label.text + "\n" + text



# adjust window depending on cell size and grid size
func set_screen_layout():
	var ss = OS.get_screen_size()	# screen width
	var ws = Vector2(data.GW, data.GH) * data.CS	# window size
	OS.set_window_size( ws )
	OS.set_window_position( (ss-ws)/2 ) # center it
