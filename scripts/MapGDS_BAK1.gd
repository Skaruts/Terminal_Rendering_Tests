extends Node2D
class_name MapGDS_BAK1

var tilemap := []

var w = 0
var h = 0

enum { FLOOR, WALL }

func _init(_w:int, _h:int) -> void:
	w = _w
	h = _h
	for i in range(w*h):
		tilemap.append(FLOOR)


	for j in range(h):
		for i in range(w):
			if i == 0 or j == 0 or i == w-1 or j == h-1\
			or utils.irand(0, 100) > 97:
				tilemap[i+j*w] = WALL


#	for j in range(h):
#		tiles.append([])
#		for i in range(w):
#			tiles[j].append(MapData.new_tile(self, i, j, Chars.WALL))

func can_move(x, y):
	return tilemap[x+y*w] != WALL

func update_stuff(terminal, cam):
	update_map(terminal, cam)

var wall_color = Color('717c8a')
var floor_color = Color('3f4956')

func update_map(terminal, cam):
	for j in range(cam.h):
		for i in range(cam.w):
			var mx = cam.mx + i
			var my = cam.my + j

			if mx >= 0 and my >= 0 and mx < w and my < h:
				var p = cam.to_cam_coords(mx, my)
				if p != null:
					if tilemap[mx+my*w] == WALL:
						terminal.set_fg(wall_color)
						terminal.put(p.x, p.y, 35)
					else:
						terminal.set_fg(floor_color)
						terminal.put(p.x, p.y, 249)

