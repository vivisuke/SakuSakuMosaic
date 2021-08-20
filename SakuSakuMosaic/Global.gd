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
]

func xyToAryIX(x, y):
	return (y+1)*ARY_WIDTH + (x+1)
func xyToBoardIX(x, y):
	return y*N_IMG_CELL_HORZ + x

func _ready():
	pass # Replace with function body.
