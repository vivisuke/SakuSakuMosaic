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
	KEY_CLUES1,
	KEY_CLUES2,
	KEY_CLUES3,
}
var quest_list = [
	["q001", 13, "Usagi", "AYAZOU",
	".........2....0 .0..3.4....4... .....3..6.3.6.. ..3.4..6..1..6. .0.............",
	"..3363.6663.6.. .0.3..6.6.466.2 ..2.....6.3.6.2 .1.33...4...... ..34..3..4.....",
	"03344.41.4.44.3 ....3..34.43..3 0.4..1.3..1.4.. ....4.......... .1.....3..34.3.",],
]

func xyToAryIX(x, y):
	return (y+1)*ARY_WIDTH + (x+1)
func xyToBoardIX(x, y):
	return y*N_IMG_CELL_HORZ + x

func _ready():
	pass # Replace with function body.
