#extends "res://scripts/gdnative/MapGDN.gdns"
#extends MapGDN     # doesn't seem to work

class_name Map
extends Node2D

var gdn_map   # temp workaround for not inheriting from it

func initialize(_w:int, _h:int) -> void:
	gdn_map = RLBaseMap.new()
	gdn_map.initialize(_w, _h)
	add_child(gdn_map)

func can_move(x, y):
	return gdn_map.can_move(x, y)

func update_stuff(terminal, cam, player_pos):
	gdn_map.recompute_fov(player_pos, data.fov_radius)
	gdn_map.update_stuff(terminal, cam)

