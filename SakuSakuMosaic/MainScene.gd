extends Node2D

onready var g = get_node("/root/Global")

const BLACK = 0
const CROSS = 1
const UNKNOWN = -1

var crnt_color = 3

func _ready():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_MiniMap()
	pass # Replace with function body.
func update_MiniMap():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$MiniTileMap.set_cell(x, y, BLACK if $BoardBG/TileMap.get_cell(x, y) == BLACK else -1)
func posToXY(pos):
	var xy = $BoardBG/TileMap.world_to_map(pos - $BoardBG/TileMap.global_position)
	if xy.x < 0 || xy.x >= g.N_IMG_CELL_HORZ || xy.y < 0 || xy.y >= g.N_IMG_CELL_VERT:
		return Vector2(-1, -1)
	return xy
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var xy = posToXY(event.position)
		print(xy)
		if xy.x >= 0:
			cell_pressed(xy.x, xy.y)
func cell_pressed(x, y):
	#print("(", x, ", ", y, ")")
	if $BoardBG/TileMap.get_cell(x, y) == UNKNOWN:
		$BoardBG/TileMap.set_cell(x, y, BLACK)
	elif $BoardBG/TileMap.get_cell(x, y) == BLACK:
		$BoardBG/TileMap.set_cell(x, y, CROSS)
	else:
		$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_MiniMap()
