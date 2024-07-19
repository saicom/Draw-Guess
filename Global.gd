extends Node


var is_connect_server = false

var all_users = []

var nick: String  #当前客户端的昵称
var cur_round: int = 0 #当前回合数，默认0
var cur_round_uid: int   #当前回合的用户uid

var server: Server


signal game_started(users)
signal round_start(uid, answer, tip)
signal chat_msg(msg)


func is_my_round():
	return cur_round_uid == multiplayer.get_unique_id()


func change_round():
	var cur_user = all_users[cur_round % all_users.size()]
	#随机题目给当前用户
	var q := server.random_question()
	for user in all_users:
		var answer = ""
		if user.uid == cur_user.uid:
			answer = q.answer
		#将题目广播给客户端
		round_change.rpc_id(user.uid, cur_user.uid, answer, q.tip)
	cur_round += 1


@rpc("any_peer")
func start_game(peer_id: int, _nick: String):
	all_users.append({"uid": peer_id, "nick": _nick})
	if all_users.size() == 2:
		print("all user ready, game start!")
		#通知客户端所有人的信息
		all_ready.rpc(all_users)
		change_round()



@rpc("any_peer")
func all_ready(users):
	if !multiplayer.is_server():
		all_users = users
		#刷新界面
		game_started.emit(users)


@rpc("any_peer")
func round_change(uid, answer, tip):
	#通知刷新提示以及问题
	round_start.emit(uid, answer, tip)



@rpc("any_peer", "call_local")
func add_chat_msg(nick, msg):
	if multiplayer.is_server():
		if msg == server.cur_answer:
			print("回答正确")
			change_round()
	else:
		#刷新消息列表
		chat_msg.emit(nick + ":" + msg)
