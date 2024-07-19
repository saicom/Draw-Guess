class_name Server
extends Node


const PORT = 8888
var peer = ENetMultiplayerPeer.new()


var all_question = [
	{"answer": "小鸡", "tip": "2个字，动物"},
	{"answer": "小鸡吃米图", "tip": "5个字，名画"},
	{"answer": "凤凰神鸟图", "tip": "5个字，也是名画"},
]

var cur_answer := ""


func _ready() -> void:
	var err := peer.create_server(PORT)
	if err != OK:
		printerr("create server fail:", err)
		return
	multiplayer.multiplayer_peer = peer
	print("create server success")


func random_question() -> Dictionary:
	var q = all_question[randi() % all_question.size()]
	cur_answer = q.answer
	return q
