extends Node2D

const BLACK = 0
const CROSS = 1
const UNKNOWN = -1

class Board:
	var g
	var ary_clues = []			#	手がかり数字配列（番人あり）、番人部分は 0
	var ary_state = []			#	状態配列（番人あり）、番人部分は CROSS
	var ix_ary = []				#	手がかり数字を消す位置配列
	
	func _init():
		g = Global
		ary_clues.resize(g.ARY_SIZE)
		ary_state.resize(g.ARY_SIZE)
		for i in range(g.ARY_SIZE):
			ary_clues[i] = 0
			ary_state[i] = CROSS
		ix_ary.resize(g.N_IMG_CELL_VERT*g.N_IMG_CELL_HORZ)
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				ix_ary[g.xyToBoardIX(x, y)] = g.xyToAryIX(x, y)
	#func xyToAryIX(x, y):		# undone: Global に移動？
	#	return (y+1)*g.ARY_WIDTH + (x+1)
	func setup(clueLabels):
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				var ix = g.xyToAryIX(x, y)
				ary_state[ix] = UNKNOWN
				var label = clueLabels[g.xyToBoardIX(x, y)]
				ary_clues[ix] = int(label.text)
				#ary_clues[ix] = -1 if label.text == "" else int(label.text)
	func print_clues():
		for y in range(g.N_IMG_CELL_VERT):
			var txt = ""
			for x in range(g.N_IMG_CELL_HORZ):
				var ix = g.xyToAryIX(x, y)
				if ary_clues[ix] < 0:
					txt += " "
				else:
					txt += String(ary_clues[ix])
			print(txt)
	func count_ary_unknown():
		var un_cnt = 0		# UNKNOWN 数
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				var ix = g.xyToAryIX(x, y)
				if ary_state[ix] == UNKNOWN:
					un_cnt += 1
		return un_cnt
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
	func solve():
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				ary_state[g.xyToAryIX(x, y)] = UNKNOWN
		var uc0 = 0
		var loop = 0
		while true:
			for y in range(g.N_IMG_CELL_VERT):
				for x in range(g.N_IMG_CELL_HORZ):
					fill_black(g.xyToAryIX(x, y))
			for y in range(g.N_IMG_CELL_VERT):
				for x in range(g.N_IMG_CELL_HORZ):
					fill_cross(g.xyToAryIX(x, y))
			var uc = count_ary_unknown()
			if uc == 0:
				return loop		# ループ回数を返す
			if uc == uc0:
				return -1
			uc0 = uc
			loop += 1
	func gen_quest(clueLabels):
		setup(clueLabels)
		ix_ary.shuffle();
		#var txt = ""
		#for i in range(ix_ary.size()):
		#	txt += String(ix_ary[i]) + " "
		#print(ix_ary)
		for i in range(ix_ary.size()):
			var ix = ix_ary[i]
			var t = ary_clues[ix]
			ary_clues[ix] = -1
			if solve() < 0:
				ary_clues[ix] = t

### End of class Board

var editMode = true		# 問題作成モード
var solving = false		# 
var solved = false
var quest_genarated = false
var crnt_color = 3
var clueLabels = []		#	手がかり数字ラベル配列（番人なし）
var ary_clues = []			#	手がかり数字配列（番人あり）、番人部分は 0
var ary_state = []			#	状態配列（番人あり）、番人部分は CROSS

var rng = RandomNumberGenerator.new()

onready var bd = Board.new()
onready var g = get_node("/root/Global")

var NumLabel = load("res://NumLabel.tscn")

func _ready():
	#print(bd.ary_clues.size())
	rng.randomize()
	editMode = true
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
			clueLabels[g.xyToBoardIX(x, y)] = nl
	update_MiniMap()
	update_ModeButtons()
	pass # Replace with function body.
#func xyToAryIX(x, y):
#	return (y+1)*g.ARY_WIDTH + (x+1)
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
			clueLabels[g.xyToBoardIX(x, y)].text = String(cnt)
			ary_clues[g.xyToAryIX(x, y)] = cnt
func update_MiniMap():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$MiniMapBG/TileMap.set_cell(x, y, BLACK if $BoardBG/TileMap.get_cell(x, y) == BLACK else -1)
func posToXY(pos):
	var xy = $BoardBG/TileMap.world_to_map(pos - $BoardBG/TileMap.global_position)
	if xy.x < 0 || xy.x >= g.N_IMG_CELL_HORZ || xy.y < 0 || xy.y >= g.N_IMG_CELL_VERT:
		return Vector2(-1, -1)
	return xy
func restore_state():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, ary_state[g.xyToAryIX(x, y)])
	quest_genarated = false
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if quest_genarated:		# 問題生成直後の場合
			restore_state()
			return
		var xy = posToXY(event.position)
		print(xy)
		if xy.x >= 0:
			cell_pressed(xy.x, xy.y)
func cell_pressed(x, y):
	#if solving:
	#	clueLabels[g.xyToBoardIX(x, y)].text = ""
	#	ary_clues[g.xyToAryIX(x, y)] = -1
	#	return
	#solving = false
	#solved = false
	#print("(", x, ", ", y, ")")
	if editMode:	# 問題作成モード
		if $BoardBG/TileMap.get_cell(x, y) != BLACK:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
		update_cluesLabel()
	else:
		if $BoardBG/TileMap.get_cell(x, y) == UNKNOWN:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
		elif $BoardBG/TileMap.get_cell(x, y) == BLACK:
			$BoardBG/TileMap.set_cell(x, y, CROSS)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	update_MiniMap()


func _on_ClearButton_pressed():
	solving = false
	solved = false
	quest_genarated = false
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
func remove_clues_randomly():
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				if rng.randi() % 100 < 40:
					clueLabels[g.xyToBoardIX(x, y)].text = ""
					ary_clues[g.xyToAryIX(x, y)] = -1
func _on_BasicButton_pressed():
	if quest_genarated:
		restore_state()
		return
	bd.gen_quest(clueLabels)
	#bd.setup(clueLabels)
	#print(bd.ary_clues)
	bd.print_clues()
	#print(bd.solve())
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			var ix = g.xyToAryIX(x, y)
			ary_state[ix] = $BoardBG/TileMap.get_cell(x, y)
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
			var c = bd.ary_clues[ix]
			clueLabels[g.xyToBoardIX(x, y)].text = String(c) if c >= 0 else ""
	var diffi = bd.solve()
	$MessLabel.text = "Difficulty = %d" % diffi
	quest_genarated = true
	return
	if !solving:
		solving = true
		remove_clues_randomly()
		$MessLabel.text = "Solving..."
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
				var ix = g.xyToAryIX(x, y)
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
				fill_black(g.xyToAryIX(x, y))
		for y in range(g.N_IMG_CELL_VERT):
			for x in range(g.N_IMG_CELL_HORZ):
				fill_cross(g.xyToAryIX(x, y))
	var un_cnt = 0		# UNKNOWN 数
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			var ix = g.xyToAryIX(x, y)
			$BoardBG/TileMap.set_cell(x, y, ary_state[ix])
			if ary_state[ix] == UNKNOWN:
				un_cnt += 1
	if un_cnt == 0:
		solved = true
		$MessLabel.text = "Solved."
	pass # Replace with function body.


func update_ModeButtons():
	$ModeContainer/SolveButton/Underline.visible = !editMode
	$ModeContainer/GenQuestButton/Underline.visible = editMode

func _on_SolveButton_pressed():
	if !editMode:
		return
	editMode = false
	update_ModeButtons()
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			ary_state[g.xyToAryIX(x, y)] = $BoardBG/TileMap.get_cell(x, y)	# 現状態を保存
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
			var label = clueLabels[g.xyToBoardIX(x, y)]
			label.add_color_override("font_color", Color.black)
	pass # Replace with function body.


func _on_GenQuestButton_pressed():
	if editMode:
		return
	editMode = true
	update_ModeButtons()
	pass # Replace with function body.
