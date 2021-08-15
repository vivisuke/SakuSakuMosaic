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

func _ready():
	pass # Replace with function body.
