extends ReferenceRect

const RADIUS = 10
const POSITION = Vector2(2, 2)
const SIZE = Vector2(480-10, 90)
const IMG_WIDTH = 20		# for 20x20
const IMG_HEIGHT = 20		# for 20x20
const TNCELLWD = 3
const THUMBNAIL_WIDTH = IMG_WIDTH*TNCELLWD
const THUMBNAIL_POS = (90-THUMBNAIL_WIDTH)/2+2
const THUMBNAIL_X = 110-30

var mouse_pushed = false
var time = 0
var saved_pos
var number :int = 0
var solved = false
var ans_iamge = []

func _ready():
	pass # Replace with function body.

func set_star(n : int):		# n: [0, 3]
	var txt = ""
	for i in range(n):
		txt += "★"
	$Star.text = txt
func set_number(n : int):
	number = n
	$Number.text = "#%d" % n
func set_difficulty(n : int):
	$Difficulty.text = "難易度 %d" % n
func set_title(ttl):
	$Title.text = "タイトル " + ttl
	solved = true
	update()
func set_author(name):
	$Author.text = "問題作者 " + name
func set_clearTime(n : int):
	time = n
	n = abs(n)
	if n < 1:
		$ClearTime.text = ""
	else:
		var h = n / (60*60)
		n -= h * (60*60)
		var m = n / 60
		var s = n % 60
		$ClearTime.text = "Time: %02d:%02d:%02d" % [h, m, s]
	update()
func _draw():
	# 外枠
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(RADIUS)
	style_box.bg_color = Color.darkslategray if !mouse_pushed else Color.gray
	style_box.border_color = Color.green if !mouse_pushed else Color.darkslategray
	style_box.set_border_width_all(2)
	style_box.shadow_offset = Vector2(4, 4) if !mouse_pushed else Vector2(0, 0)
	style_box.shadow_size = 8 # if !mouse_pushed else 4
	draw_style_box(style_box, Rect2(POSITION, SIZE))
	# サムネイル
	var col = Color.lightgray if ans_iamge.empty() else Color("#ffffef") if time >= 0 else Color("#ffffc0")	#.lightyellow
	draw_rect(Rect2(THUMBNAIL_X-2, THUMBNAIL_POS-2, THUMBNAIL_WIDTH+4, THUMBNAIL_WIDTH+4), col)
	if !ans_iamge.empty():
		for y in range(IMG_HEIGHT):
			#print(ans_iamge[i])
			var py = y * TNCELLWD + THUMBNAIL_POS
			var mask = 1 << IMG_WIDTH
			for x in range(IMG_WIDTH):
				mask >>= 1
				if (ans_iamge[y] & mask) != 0:
					var px = x * TNCELLWD + THUMBNAIL_X
					draw_rect(Rect2(px, py, TNCELLWD, TNCELLWD), Color.black)
