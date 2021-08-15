extends Node2D

onready var g = get_node("/root/Global")

const BLACK = 0
const CROSS = 1
const UNKNOWN = -1

var crnt_color = 3
var clues = []
var clueLabels = []

var NumLabel = load("res://NumLabel.tscn")

func _ready():
	clues.resize(g.ARY_SIZE)
	for i in range(g.ARY_SIZE):
		clues[i] = 0
	clueLabels.resize(g.N_IMG_CELL_HORZ*g.N_IMG_CELL_VERT)
	for y in range(g.N_IMG_CELL_VERT):
		var py = y * g.CELL_WIDTH
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
			var px = x * g.CELL_WIDTH
			var nl = NumLabel.instance()
			nl.add_color_override("font_color", Color.gray)
			#if y % 2 == 0:
			#	nl.add_color_override("font_color", Color.gray)
			#else:
			#	nl.add_color_override("font_color", Color.green)
			nl.rect_position = Vector2(px, py)
			#nl.text = String(x % 10)
			$BoardBG.add_child(nl)
			clueLabels[x+y*g.N_IMG_CELL_HORZ] = nl
	update_MiniMap()
	pass # Replace with function body.
func xyToAryIX(x, y):
	return (y+1)*g.ARY_WIDTH + (x+1)
func count_black(x, y):
	var cnt = 0
	if( $BoardBG/TileMap.get_cell(x-1, y-1) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y-1) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y-1) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x-1, y) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x-1, y+1) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y+1) == BLACK ):
		cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y+1) == BLACK ):
		cnt += 1;
	return cnt
func update_clues():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			var cnt = count_black(x, y)
			clueLabels[x+y*g.N_IMG_CELL_HORZ].text = String(cnt)
			#var ix = xyToAryIX(x, y)
func update_MiniMap():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$MiniMapBG/TileMap.set_cell(x, y, BLACK if $BoardBG/TileMap.get_cell(x, y) == BLACK else -1)
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
	update_clues()


func _on_ClearButton_pressed():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_clues()
	update_MiniMap()
	pass # Replace with function body.
func _on_BasicButton_pressed():
	pass # Replace with function body.


