extends Node2D

const BLACK = 0
const CROSS = 1
const UNKNOWN = -1

const TILE_NONE = -1
const TILE_CROSS = 0		# ☓
const TILE_BLACK = 1
const TILE_BG_YELLOW = 0
const TILE_BG_GRAY = 1

enum { MODE_SOLVE, MODE_EDIT_PICT, MODE_EDIT_CLUES, }
enum { SET_CELL, SET_CELL_BE, CLEAR_ALL, ROT_LEFT, ROT_RIGHT, ROT_UP, ROT_DOWN}

var qix					# 問題番号 [0, N]
var qID					# 問題ID
var qSolved = false		# 現問題をクリア済みか？
var qSolvedStat = false		# 現問題をクリア状態か？
var elapsedTime = 0.0	# 経過時間（単位：秒）
var hintTime = 0.0		# != 0 の間はヒント使用不可（単位：秒）
var mode = MODE_EDIT_PICT;
var dialog_opened = false;
var mouse_pushed = false
var last_xy = Vector2()
var pushed_xy = Vector2()
var cell_val = 0

var editMode = true			# 問題作成モード
var pressed = false;		# true for マウス押下時
var long_pressed = false	# 長押しされた
var solving = false			# 
var solved = false
var quest_genarated = false
var crnt_color = 3
var pressed_ticks = 0		# 押下時タイム
var pressed_xy = Vector2(-1, -1)
var clueLabels = []			#	手がかり数字ラベル配列（番人なし）
var saved_state = []		#	問題状態保存用（番人なし）
var ary_clues = []			#	手がかり数字配列（番人あり）、番人部分は 0
var ary_state = []			#	状態配列（番人あり）、番人部分は CROSS

var rng = RandomNumberGenerator.new()

onready var bd = Board.new()
onready var g = get_node("/root/Global")

var NumLabel = load("res://NumLabel.tscn")

func _ready():
	#print(bd.ary_clues.size())
	rng.randomize()
	editMode = !g.solveMode
	qix = g.qNumber - 1
	ary_clues.resize(g.ARY_SIZE)
	ary_state.resize(g.ARY_SIZE)
	for i in range(g.ARY_SIZE):
		ary_clues[i] = 0
		ary_state[i] = CROSS
	clueLabels.resize(g.N_IMG_CELL_HORZ*g.N_IMG_CELL_VERT)
	saved_state.resize(g.N_IMG_CELL_HORZ*g.N_IMG_CELL_VERT)
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
	if !editMode:
		set_quest(g.quest_list[qix][g.KEY_CLUES])
	update_MiniMap()
	update_ModeButtons()
	pass # Replace with function body.
func saveSolvedPat():
	var file = File.new()
	file.open(g.solvedPatFileName, File.WRITE)
	file.store_var(g.solvedPat)
	file.close()
func saveSettings():
	var file = File.new()
	file.open(g.settingsFileName, File.WRITE)
	file.store_var(g.settings)
	file.close()
func set_quest(quest : String):
	if editMode: return
	var x = 0
	var y = 0
	for i in range(quest.length()):
		if quest[i] == ".":
			clueLabels[g.xyToBoardIX(x, y)].text = ""
		elif quest.ord_at(i) >= 0x30 && quest.ord_at(i) <= 0x39:
			clueLabels[g.xyToBoardIX(x, y)].text = String(quest.ord_at(i) - 0x30)
		else:
			continue
		x += 1
		if x == g.N_IMG_CELL_HORZ:
			x = 0
			y += 1
	pass
func get_h_data(y0):
	var data = 0
	for x in range(g.N_IMG_CELL_HORZ):
		data = data * 2 + (1 if $BoardBG/TileMap.get_cell(x, y0) == TILE_BLACK else 0)
	return data
func get_h_data0(y0):
	var data = 0
	for x in range(g.N_IMG_CELL_HORZ):
		data = data * 2 + (1 if $BoardBG/TileMap.get_cell(x, y0) == TILE_CROSS else 0)
	return data
func get_v_data(x0):
	var data = 0
	for y in range(g.N_IMG_CELL_VERT):
		data = data * 2 + (1 if $BoardBG/TileMap.get_cell(x0, y) == TILE_BLACK else 0)
	return data
func get_v_data0(x0):
	var data = 0
	for y in range(g.N_IMG_CELL_VERT):
		data = data * 2 + (1 if $BoardBG/TileMap.get_cell(x0, y) == TILE_CROSS else 0)
	return data
#func xyToAryIX(x, y):
#	return (y+1)*g.ARY_WIDTH + (x+1)
func count_black(x, y):		# (x, y) を中心とする 3x3 ブロック内の黒数をカウント
	var cnt = 0
	if( $BoardBG/TileMap.get_cell(x-1, y-1) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y-1) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y-1) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x-1, y) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x-1, y+1) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y+1) == BLACK ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x+1, y+1) == BLACK ): cnt += 1;
	return cnt
func count_cross(x, y):		# (x, y) を中心とする 3x3 ブロック内のバツ数をカウント（盤外はバツとみなす）
	var cnt = 0
	if( x == 0 || y == 0 || $BoardBG/TileMap.get_cell(x-1, y-1) == CROSS ): cnt += 1;
	if( y == 0 || $BoardBG/TileMap.get_cell(x, y-1) == CROSS ): cnt += 1;
	if( x == g.N_IMG_CELL_HORZ - 1 || y == 0 || $BoardBG/TileMap.get_cell(x+1, y-1) == CROSS ): cnt += 1;
	if( x == 0 || $BoardBG/TileMap.get_cell(x-1, y) == CROSS ): cnt += 1;
	if( $BoardBG/TileMap.get_cell(x, y) == CROSS ): cnt += 1;
	if( x == g.N_IMG_CELL_HORZ - 1 || $BoardBG/TileMap.get_cell(x+1, y) == CROSS ): cnt += 1;
	if( x == 0 || y == g.N_IMG_CELL_VERT - 1 || $BoardBG/TileMap.get_cell(x-1, y+1) == CROSS ): cnt += 1;
	if( y == g.N_IMG_CELL_VERT - 1 || $BoardBG/TileMap.get_cell(x, y+1) == CROSS ): cnt += 1;
	if( x == g.N_IMG_CELL_HORZ - 1 || y == g.N_IMG_CELL_VERT - 1 || $BoardBG/TileMap.get_cell(x+1, y+1) == CROSS ): cnt += 1;
	return cnt
func count_ary_black(ix):		#	ix を中心とする 3x3 ブロック内の 黒 数を数える
	var cnt = 0
	if( ary_state[ix-g.ARY_WIDTH-1] == BLACK ): cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH] == BLACK ): cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH+1] == BLACK ): cnt += 1;
	if( ary_state[ix-1] == BLACK ): cnt += 1;
	if( ary_state[ix] == BLACK ): cnt += 1;
	if( ary_state[ix+1] == BLACK ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH-1] == BLACK ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH] == BLACK ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH+1] == BLACK ): cnt += 1;
	return cnt
func count_ary_cross(ix):		#	ix を中心とする 3x3 ブロック内の バツ 数を数える
	var cnt = 0
	if( ary_state[ix-g.ARY_WIDTH-1] == CROSS ): cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH] == CROSS ): cnt += 1;
	if( ary_state[ix-g.ARY_WIDTH+1] == CROSS ): cnt += 1;
	if( ary_state[ix-1] == CROSS ): cnt += 1;
	if( ary_state[ix] == CROSS ): cnt += 1;
	if( ary_state[ix+1] == CROSS ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH-1] == CROSS ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH] == CROSS ): cnt += 1;
	if( ary_state[ix+g.ARY_WIDTH+1] == CROSS ): cnt += 1;
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
	if event is InputEventMouseButton:
		var xy = posToXY(event.position)
		print(xy)
		if event.doubleclick: print("doubleclick")
		elif event.pressed:
			print("pressed")
			pressed = true
			pressed_xy = xy
			pressed_ticks = OS.get_ticks_msec()
		else:	# released
			print("released")
			if quest_genarated:		# 問題生成直後の場合
				restore_state()
				return
			if long_pressed: long_pressed = false
			elif xy.x >= 0 && xy == pressed_xy:
				cell_pressed(xy.x, xy.y)
				$PressedAudio.play()
			pressed = false
		#elif event.doubleclick:
		#	print("doubleclick")
func _process(delta):
	if pressed && !long_pressed && !editMode:
		if OS.get_ticks_msec() - pressed_ticks >= 500:		# 0.5秒経過
			print("long_pressed")
			long_pressed = true
			cell_long_pressed()
			$PressedAudio.play()
func update_cluesLabelColor(x, y):
	if x < 0 || x >= g.N_IMG_CELL_HORZ || y < 0 || y >= g.N_IMG_CELL_VERT:
		return
	var label = clueLabels[g.xyToBoardIX(x, y)]
	if label.text == "":
		return
	var cn = int(label.text)		# 手がかり数字
	var cb = count_black(x, y)		# 3x3 領域内黒数
	var cc = count_cross(x, y)		# 3x3 領域内バツ数
	var col
	if cb + cc == 9:	# 全部埋まっている場合
		col = Color.gray if cb == cn else Color.red			# 正しければグレイ、間違っていれば赤
	elif cb == cn: col = Color.green		# 手がかり数字の数だけ黒がある場合
	elif cb > cn: col = Color.red			# 手がかり数字の数より黒が多い場合
	else:
		col = Color.white if $BoardBG/TileMap.get_cell(x, y) == BLACK else Color.black
	clueLabels[g.xyToBoardIX(x, y)].add_color_override("font_color", col)
func update_allCluesLabel():
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			update_cluesLabelColor(x, y)
func cell_pressed(x, y):
	#if solving:
	#	clueLabels[g.xyToBoardIX(x, y)].text = ""
	#	ary_clues[g.xyToAryIX(x, y)] = -1
	#	return
	#solving = false
	#solved = false
	#print("(", x, ", ", y, ")")
	if editMode:	# 問題を作る モード
		if $BoardBG/TileMap.get_cell(x, y) != BLACK:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
		update_cluesLabel()
	else:			# 問題を解くモード
		if $BoardBG/TileMap.get_cell(x, y) == UNKNOWN:
			$BoardBG/TileMap.set_cell(x, y, BLACK)
			#clueLabels[g.xyToBoardIX(x, y)].add_color_override("font_color", Color.white)
		elif $BoardBG/TileMap.get_cell(x, y) == BLACK:
			$BoardBG/TileMap.set_cell(x, y, CROSS)
			#clueLabels[g.xyToBoardIX(x, y)].add_color_override("font_color", Color.black)
		else:
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
			#clueLabels[g.xyToBoardIX(x, y)].add_color_override("font_color", Color.black)
		for v in range(-1, 2):
			for h in range(-1, 2):
				update_cluesLabelColor(x+h, y+v)
	update_MiniMap()
func set_cell(x, y, v):
	if x >= 0 && x < g.N_IMG_CELL_HORZ && y >= 0 && y < g.N_IMG_CELL_VERT:
		$BoardBG/TileMap.set_cell(x, y, v)
func cell_long_pressed():
	var x = pressed_xy.x
	var y = pressed_xy.y
	var label = clueLabels[g.xyToBoardIX(x, y)]
	if label.text == "": return
	var cn = int(label.text)
	var cb = count_black(x, y)
	var cc = count_cross(x, y)
	if cn == 0:
		for h in range(-1, 2):
			for v in range(-1, 2):
				set_cell(x+h, y+v, CROSS)
	elif cn == cb:
		for h in range(-1, 2):
			for v in range(-1, 2):
				if $BoardBG/TileMap.get_cell(x+h, y+v) == UNKNOWN:
					set_cell(x+h, y+v, CROSS)
	elif cn + cc == 9:
		for h in range(-1, 2):
			for v in range(-1, 2):
				if $BoardBG/TileMap.get_cell(x+h, y+v) == UNKNOWN:
					set_cell(x+h, y+v, BLACK)
	else:
		return
	for h in range(-2, 3):
		for v in range(-2, 3):
			update_cluesLabelColor(x+h, y+v)
	update_MiniMap()
	pass
func _on_ClearButton_pressed():
	solving = false
	solved = false
	quest_genarated = false
	$MessLabel.text = ""
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	if editMode:
		update_cluesLabel()
	else:
		update_allCluesLabel()
	update_MiniMap()
	pass # Replace with function body.
func fill_black(ix):	# 手がかり数字＋周りのバツ数が９ならばバツ以外の場所を黒にする
	var cnt = count_ary_cross(ix)
	if ary_clues[ix] >= 0 && ary_clues[ix] + cnt == 9:
		if ary_state[ix-g.ARY_WIDTH-1] == UNKNOWN: ary_state[ix-g.ARY_WIDTH-1] = BLACK
		if ary_state[ix-g.ARY_WIDTH] == UNKNOWN: ary_state[ix-g.ARY_WIDTH] = BLACK
		if ary_state[ix-g.ARY_WIDTH+1] == UNKNOWN: ary_state[ix-g.ARY_WIDTH+1] = BLACK
		if ary_state[ix-1] == UNKNOWN: ary_state[ix-1] = BLACK
		if ary_state[ix] == UNKNOWN: ary_state[ix] = BLACK
		if ary_state[ix+1] == UNKNOWN: ary_state[ix+1] = BLACK
		if ary_state[ix+g.ARY_WIDTH-1] == UNKNOWN: ary_state[ix+g.ARY_WIDTH-1] = BLACK
		if ary_state[ix+g.ARY_WIDTH] == UNKNOWN: ary_state[ix+g.ARY_WIDTH] = BLACK
		if ary_state[ix+g.ARY_WIDTH+1] == UNKNOWN: ary_state[ix+g.ARY_WIDTH+1] = BLACK
func fill_cross(ix):	# 手がかり数字 == 周りの黒数 ならば UNKNOWN の場所をバツにする
	var cnt = count_ary_black(ix)
	if ary_clues[ix] >= 0 && ary_clues[ix] == cnt:
		if ary_state[ix-g.ARY_WIDTH-1] == UNKNOWN: ary_state[ix-g.ARY_WIDTH-1] = CROSS
		if ary_state[ix-g.ARY_WIDTH] == UNKNOWN: ary_state[ix-g.ARY_WIDTH] = CROSS
		if ary_state[ix-g.ARY_WIDTH+1] == UNKNOWN: ary_state[ix-g.ARY_WIDTH+1] = CROSS
		if ary_state[ix-1] == UNKNOWN: ary_state[ix-1] = CROSS
		if ary_state[ix] == UNKNOWN: ary_state[ix] = CROSS
		if ary_state[ix+1] == UNKNOWN: ary_state[ix+1] = CROSS
		if ary_state[ix+g.ARY_WIDTH-1] == UNKNOWN: ary_state[ix+g.ARY_WIDTH-1] = CROSS
		if ary_state[ix+g.ARY_WIDTH] == UNKNOWN: ary_state[ix+g.ARY_WIDTH] = CROSS
		if ary_state[ix+g.ARY_WIDTH+1] == UNKNOWN: ary_state[ix+g.ARY_WIDTH+1] = CROSS
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

func update_ModeButtons():
	$ModeContainer/SolveButton/Underline.visible = !editMode
	$ModeContainer/EditPictButton/Underline.visible = editMode

func _on_SolveButton_pressed():
	if !editMode:
		return
	editMode = false
	update_ModeButtons()
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			ary_state[g.xyToAryIX(x, y)] = $BoardBG/TileMap.get_cell(x, y)	# 現状態を保存
			$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
			#var label = clueLabels[g.xyToBoardIX(x, y)]
			#label.add_color_override("font_color", Color.gray)
	update_allCluesLabel()
	pass # Replace with function body.

func _on_EditPictButton_pressed():
	if editMode:
		return
	editMode = true
	update_ModeButtons()
	for y in range(g.N_IMG_CELL_VERT):
		for x in range(g.N_IMG_CELL_HORZ):
			clueLabels[g.xyToBoardIX(x, y)].add_color_override("font_color", Color.gray)
			$BoardBG/TileMap.set_cell(x, y, ary_state[g.xyToAryIX(x, y)])
			#$BoardBG/TileMap.set_cell(x, y, UNKNOWN)
	pass # Replace with function body.


func _on_TestButton_pressed():
	if editMode:
		return
	set_quest(g.quest_list[0][g.KEY_CLUES])
	update_allCluesLabel()
	pass # Replace with function body.


func rotate_left_basic():
	var ar = []
	for y in range(g.N_IMG_CELL_VERT):
		ar.push_back($BoardBG/TileMap.get_cell(0, y))	# may be -1 or +1
	for x in range(g.N_IMG_CELL_HORZ-1):
		for y in range(g.N_IMG_CELL_VERT):
			$BoardBG/TileMap.set_cell(x, y, $BoardBG/TileMap.get_cell(x+1, y))
	for y in range(g.N_IMG_CELL_VERT):
		$BoardBG/TileMap.set_cell(g.N_IMG_CELL_HORZ-1, y, ar[y])
	update_cluesLabel()
	update_MiniMap()
func _on_LeftButton_pressed():
	rotate_left_basic()
	pass # Replace with function body.
func rotate_down_basic():
	var ar = []
	for x in range(g.N_IMG_CELL_HORZ):
		ar.push_back($BoardBG/TileMap.get_cell(x, g.N_IMG_CELL_VERT-1))	# may be -1 or +1
	for y in range(g.N_IMG_CELL_VERT-1, 0, -1):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, $BoardBG/TileMap.get_cell(x, y-1))
	for x in range(g.N_IMG_CELL_HORZ):
		$BoardBG/TileMap.set_cell(x, 0, ar[x])
	update_cluesLabel()
	update_MiniMap()
func _on_DownButton_pressed():
	rotate_down_basic()
	pass # Replace with function body.
func rotate_up_basic():
	var ar = []
	for x in range(g.N_IMG_CELL_HORZ):
		ar.push_back($BoardBG/TileMap.get_cell(x, 0))	# may be -1 or +1
	for y in range(g.N_IMG_CELL_VERT-1):
		for x in range(g.N_IMG_CELL_HORZ):
			$BoardBG/TileMap.set_cell(x, y, $BoardBG/TileMap.get_cell(x, y+1))
	for x in range(g.N_IMG_CELL_HORZ):
		$BoardBG/TileMap.set_cell(x, g.N_IMG_CELL_VERT-1, ar[x])
	update_cluesLabel()
	update_MiniMap()
func _on_UpButton_pressed():
	rotate_up_basic()
	pass # Replace with function body.
func rotate_right_basic():
	var ar = []
	for y in range(g.N_IMG_CELL_VERT):
		ar.push_back($BoardBG/TileMap.get_cell(g.N_IMG_CELL_HORZ-1, y))	# may be -1 or +1
	for x in range(g.N_IMG_CELL_HORZ-1, 0, -1):
		for y in range(g.N_IMG_CELL_VERT):
			$BoardBG/TileMap.set_cell(x, y, $BoardBG/TileMap.get_cell(x-1, y))
	for y in range(g.N_IMG_CELL_VERT):
		$BoardBG/TileMap.set_cell(0, y, ar[y])
	update_cluesLabel()
	update_MiniMap()
func _on_RightButton_pressed():
	rotate_right_basic()
	pass # Replace with function body.


func _on_BackButton_pressed():
	if !qSolved && !qSolvedStat:
		var lst = []
		for y in range(g.N_IMG_CELL_VERT):
			lst.push_back(get_h_data(y))
		lst.push_back(-int(elapsedTime))
		for y in range(g.N_IMG_CELL_VERT):
			lst.push_back(get_h_data0(y))
		g.solvedPat[qID] = lst
		saveSolvedPat()
	get_tree().change_scene("res://LevelScene.tscn")
	pass # Replace with function body.

### class Board
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
					txt += "."
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
