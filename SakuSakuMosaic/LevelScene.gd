extends Node2D

const N_IMG_CELL_VERT = 15
const PANEL_HEIGHT = 100

onready var g = get_node("/root/Global")

var dialog_opened = false
var mouse_pushed = false
var mouse_pos
var scroll_pos

var QuestPanel = load("res://QuestPanel.tscn")


func _ready():
	#
	g.ans_images.resize(g.quest_list.size())
	g.qix2ID.resize(g.quest_list.size())
	var score = 0
	var nSolved = 0
	for i in g.quest_list.size():	# 問題パネルセットアップ
		#if g.solved.size() <= i:
		#	g.solved.push_back(false)
		#var qix = g.qNum2QIX[i]
		var qix = i
		g.qix2ID[qix] = g.quest_list[qix][g.KEY_ID]
		var panel = QuestPanel.instance()
		panel.set_number(i+1)
		var diffi = g.quest_list[qix][g.KEY_DIFFICULTY]
		panel.set_difficulty(diffi)
		#if g.solved[i]:
		var ns = 0
		var solved = false;
		if g.solvedPat.has(g.qix2ID[qix]):		# クリア済み or 途中経過あり
			var lst = g.solvedPat[g.qix2ID[qix]]
			if lst.size() <= g.N_IMG_CELL_VERT || lst[g.N_IMG_CELL_VERT] > 0:
				solved = true
				panel.set_title(g.quest_list[qix][g.KEY_TITLE])
			else:
				panel.set_title(g.quest_list[qix][g.KEY_TITLE][0] + "???")
			panel.set_ans_image(lst)
			#panel.set_ans_image(g.ans_images[i])
			#panel.set_clearTime(lst[N_IMG_CELL_VERT] if lst.size() > N_IMG_CELL_VERT else 0)
			if lst.size() > g.N_IMG_CELL_VERT:	# クリアタイムあり
				panel.set_clearTime(lst[g.N_IMG_CELL_VERT])
				if solved:
					if lst[g.N_IMG_CELL_VERT] < diffi * 60 * 0.5:
						ns = 3
					elif lst[g.N_IMG_CELL_VERT] < diffi * 60:
						ns = 2
					elif lst[g.N_IMG_CELL_VERT] < diffi * 60 * 2:
						ns = 1
			else:
				panel.set_clearTime(0)
		else:
			panel.set_title(g.quest_list[qix][g.KEY_TITLE][0] + "???")
			panel.set_clearTime(0)
		if solved:
			nSolved += 1
			score += diffi * (10 + ns*2)
		panel.set_star(ns)
		panel.set_author(g.quest_list[qix][g.KEY_AUTHOR])
		$ScrollContainer/VBoxContainer.add_child(panel)
		#
		panel.connect("pressed", self, "_on_QuestPanel_pressed")
	#$scoreLabel.text = "SCORE: %d" % score
	#var pc : int = round(nSolved * 100.0 / g.quest_list.size())
	#$solvedLabel.text = "Solved: %d/%d (%d%%)" % [nSolved, g.quest_list.size(), pc]
	#print("vscroll = ", g.lvl_vscroll)
	#$ScrollContainer.set_v_scroll(g.lvl_vscroll)
