extends Node2D

onready var g = get_node("/root/Global")

const BLACK = 0
const CROSS = 1
const UNKNOWN = -1

var solving = false		# 
var solved = false
var crnt_color = 3
var clueLabels = []		#	手がかり数字ラベル配列（番人なし）
var ary_clues = []			#	手がかり数字配列（番人あり）、番人部分は 0
var ary_state = []			#	状態配列（番人あり）、番人部分は CROSS

var NumLabel = load("res://NumLabel.tscn")

func _ready():
	ary_clues.resize(g.ARY_SIZE)
	ary_state.resize(g.ARY_SIZE)
	for i in range(g.ARY_SIZE):
		ary_clues[i] = 0
		ary_state[i] = CROSS
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
func count_ary_black(ix):		#	ix を中心とする 3x3 ブロック内の 黒 数を数える
	var cnt = 0
	if( ary_state[ix-g.ARY_WIDTH-1] == BLACK ):
		cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH] == BLACK ):
		cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH+1] == BLACK ):
		cnt += 1;
	if( ary_state[ix-1] == BLACK ):
		cnt += 1;
	if( ary_state[ix] == BLACK ):
		cnt += 1;
	if( ary_state[ix+1] == BLACK ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH-1] == BLACK ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH] == BLACK ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH+1] == BLACK ):
		cnt += 1;
	return cnt
func count_ary_cross(ix):		#	ix を中心とする 3x3 ブロック内の バツ 数を数える
	var cnt = 0
	if( ary_state[ix-g.ARY_WIDTH-1] == CROSS ):
		cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH] == CROSS ):
		cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH+1] == CROSS ):
		cnt += 1;
	if( ary_state[ix-1] == CROSS ):
		cnt += 1;
	if( ary_state[ix] == CROSS ):
		cnt += 1;
	if( ary_state[ix+1] == CROSS ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH-1] == CROSS ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH] == CROSS ):
		cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH+1] == CROSS ):
		cnt += 1;
	return cnt
func update_cluesLabel():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			var cnt = count_black(x, y)
			clueLabels[x+y*g.N_IMG_CELL_HORZ].text = String(cnt)
			ary_clues[xyToAryIX(x, y)] = cnt
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
	if solving:
		clueLabels[x+y*g.N_IMG_CELL_HORZ].text = ""
		ary_clues[xyToAryIX(x, y)] = -1
		return
	#solving = false
	#solved = false
	#print("(", x, ", ", y, ")")
	if true:	# 問題作成モード
		if $BoardBG/TileMap.get_cell(x, y) != BLACK:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	else:
		if $BoardBG/TileMap.get_cell(x, y) == UNKNOWN:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
		elif $BoardBG/TileMap.get_cell(x, y) == BLACK:
			$BoardBG/TileMap.set_cell(x, y, CROSS)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_MiniMap()
	update_cluesLabel()


func _on_ClearButton_pressed():
	solving = false
	solved = false
	$MessLabel.text = ""
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_cluesLabel()
	update_MiniMap()
	pass # Replace with function body.
func fill_black(ix):	# 手がかり数字＋周りのバツ数が９ならばバツ以外の場所を黒にする
	var cnt = count_ary_cross(ix)
	if ary_clues[ix] >= 0 && ary_clues[ix] + cnt == 9:
		if ary_state[ix-g.ARY_WIDTH-1] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH-1] = BLACK
		if ary_state[ix-g.ARY_WIDTH] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH] = BLACK
		if ary_state[ix-g.ARY_WIDTH+1] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH+1] = BLACK
		if ary_state[ix-1] == UNKNOWN:
			ary_state[ix-1] = BLACK
		if ary_state[ix] == UNKNOWN:
			ary_state[ix] = BLACK
		if ary_state[ix+1] == UNKNOWN:
			ary_state[ix+1] = BLACK
		if ary_state[ix+g.ARY_WIDTH-1] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH-1] = BLACK
		if ary_state[ix+g.ARY_WIDTH] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH] = BLACK
		if ary_state[ix+g.ARY_WIDTH+1] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH+1] = BLACK
func fill_cross(ix):	# 手がかり数字 == 周りの黒数 ならば UNKNOWN の場所をバツにする
	var cnt = count_ary_black(ix)
	if ary_clues[ix] >= 0 && ary_clues[ix] == cnt:
		if ary_state[ix-g.ARY_WIDTH-1] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH-1] = CROSS
		if ary_state[ix-g.ARY_WIDTH] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH] = CROSS
		if ary_state[ix-g.ARY_WIDTH+1] == UNKNOWN:
			ary_state[ix-g.ARY_WIDTH+1] = CROSS
		if ary_state[ix-1] == UNKNOWN:
			ary_state[ix-1] = CROSS
		if ary_state[ix] == UNKNOWN:
			ary_state[ix] = CROSS
		if ary_state[ix+1] == UNKNOWN:
			ary_state[ix+1] = CROSS
		if ary_state[ix+g.ARY_WIDTH-1] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH-1] = CROSS
		if ary_state[ix+g.ARY_WIDTH] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH] = CROSS
		if ary_state[ix+g.ARY_WIDTH+1] == UNKNOWN:
			ary_state[ix+g.ARY_WIDTH+1] = CROSS
func _on_BasicButton_pressed():
	if !solving:
		solving = true
		$MessLabel.text = "Solving..."
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
				var ix = xyToAryIX(x, y)
				ary_state[ix] = UNKNOWN
	elif solved:
		solving = false
		solved = false
		$MessLabel.text = ""
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				if $BoardBG/TileMap.get_cell(x, y) == CROSS:
					$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
		return
	else:
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				fill_black(xyToAryIX(x, y))
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				fill_cross(xyToAryIX(x, y))
	var un_cnt = 0		# UNKNOWN 数
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			var ix = xyToAryIX(x, y)
			$BoardBG/TileMap.set_cell(x, y, ary_state[ix])
			if ary_state[ix] == UNKNOWN:
				un_cnt += 1
	if un_cnt == 0:
		solved = true
		$MessLabel.text = "Solved."
	pass # Replace with function body.


