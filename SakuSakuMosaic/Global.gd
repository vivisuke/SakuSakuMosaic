extends Node2D


const SCREEN_WIDTH = 500.0
const SCREEN_HEIGHT = 800.0
const BOARD_WIDTH = 480.0
const BOARD_HEIGHT = BOARD_WIDTH

const N_IMG_CELL_HORZ = 15		# 画像 セル数
const N_IMG_CELL_VERT = 15		# 画像 セル数
const CELL_WIDTH = BOARD_WIDTH / N_IMG_CELL_HORZ
const ARY_WIDTH = N_IMG_CELL_HORZ + 2
const ARY_HEIGHT = N_IMG_CELL_VERT + 2
const ARY_SIZE = ARY_WIDTH * ARY_HEIGHT

const solvedPatFileName = "user://SSM15_saved.dat"
const settingsFileName = "user://SSM15_stgs.dat"

var lang_ja = false		# 日本語モード？
var solvedPatLoaded = false
var lvl_vscroll = 0		# レベルシーン スクロール位置
var solveMode = true
var qNumber = 0			# [#1, ...#N]
var qNum2QIX = []		# qNum (#1 ... #N) → QIX テーブル
var qix2ID = []			# qix → QID 配列
var settings = {}		# 設定辞書
var solvedPat = {}		# QID -> [data0, data1, ...] 辞書
#var solved = []			# true/false
var ans_images = []		# 解答ビットパターン配列

enum {
	KEY_ID = 0,
	KEY_DIFFICULTY,
	KEY_TITLE,
	KEY_AUTHOR,
	KEY_CLUES,
}
var quest_list = [
	#["q000", 3, "Albert", "mamimumemo",
	#"""	0....0....0.... ..0....0.....0. 0...0...11..... ..0.....2.0..0. .....3........0
	#	.0..0.2...0.... ..0....5...1... ....3....43.00. .0.....5....... ...033..5330..0
	#	.......45..0... .0...2.......0. ...0........... ......0..0.0..0 0.0.0.......... """,],
	["q001", 13, "Usagi", "AYAZOU",
	"""	.........2....0 .0..3.4....4... .....3..6.3.6.. ..3.4..6..1..6. .0............. 
		..3363.6663.6.. .0.3..6.6.466.2 ..2.....6.3.6.2 .1.33...4...... ..34..3..4..... 
		03344.41.4.44.3 ....3..34.43..3 0.4..1.3..1.4.. ....4.......... .1.....3..34.3. """,],
	#["q002", 12, "Controller", "vivisuke",
	#"""	.........2....0 .2..7.1.1.78.2. ...9........6.. 035.8....788..0 ....765..67....
	#	..5566.3..6.... 3.....7.77.67.3 ..8.7..9...88.3 .7..6.6.65..... ..9............
	#	6..86.6..5..9.6 .......65...... 6.9.5..3.35..9. ..8.2....0..8.. .5.....0..1..5. """,],
	["q002", 12, "51", "vivisuke",
	"""	1....5....0.2.. .6..9...1..1.4. ..9..9...2.12.2 68......5..011. .........2....0
	.7887433..0..0. ..7.42........0 .577....322.32. .44...44......3 2..3....34.6..3
	.3..1.0.2..7... .....1..00..75. 5.53...2224.5.. ....31...333..0 3.42..1........ """,],
	["q003", 9, "Kyoro-chan", "vivisuke",
	"""	.........42.0.. .0..3.5......0. .013.6.45.6.3.. 0...6..6.6....0 ...4..6...46...
	...21.68..6.8.. 2.....3.6.....3 ..3..0.45..89.3 .4.10...2...... ..5...3..0.....
	...5.....01.4.1 0.....100.....0 ..1.333..44..0. ..012...4...0.. .0.0...4..31.0.""",],
	["q004", 15, "SACHIEL", "vivisuke",
	"""	...34.4...4.... .5.......6.4.5. 3.1.6.5.5.6.13. ..24..3.3...2.. .3..77.446.4.3.
	..679..457866.. .....87..8..... .1.5.7.7.....1. .033656.65.3... .....554..5....
	...........3.2. 03.3...8.....30 1.3...6..3..33. .......9..1...2 .210..5...101..""",],
	["q005", 20, "KING", "vivisuke",
	"""	13..1.231...1.1 ..55.5...5553.. 4.765..6...6..4 4.75556...6...4 .5..6....6..8.4
	.4..4..3..4.6.3 ..4244...64.6.. .5.0..133.1447. .4...0.4.3...8. .431..1..2..4..
	3.2..34.5.....5 ...2...3..1347. .5...2.5.32356. ..643....22445. .2..3.1.2......""",],
	["q006", 5, "smile", "vivisuke",
	"""	0...0..0....... ..0......0.0..0 0...0......0... ......0...0.... .0....10......0
	....2..22...0.0 ..0..3....2.... .0.1..1.12..... ..0..1...1...0. .0..........0..
	..0..1.3.1..... 0......0.....0. ...........0... ..0..0...0..00. .0......0......""",],
]

func xyToAryIX(x, y):
	return (y+1)*ARY_WIDTH + (x+1)
func xyToBoardIX(x, y):
	return y*N_IMG_CELL_HORZ + x

func _ready():
	pass # Replace with function body.
