extends Control

@onready var nick_edit: LineEdit = $LoginPanel/NickEdit
@onready var user_list_container: VBoxContainer = $UserListPanel/UserListContainer
@onready var msg_container: VBoxContainer = $ChatPanel/ScrollContainer/MsgContainer
@onready var msg_edit: LineEdit = $ChatPanel/HBoxContainer/MsgEdit
@onready var send_msg_btn: Button = $ChatPanel/HBoxContainer/SendMsgBtn
@onready var login_panel: ColorRect = $LoginPanel
@onready var tip_label: Label = $TipLabel
@onready var pen_container: HBoxContainer = $PenContainer


func _ready() -> void:
	Global.game_started.connect(on_game_started)
	Global.round_start.connect(on_round_started)
	Global.chat_msg.connect(on_chat_msg)


func _on_start_game_button_pressed() -> void:
	if !Global.is_connect_server:
		print("连接服务器失败，无法进入游戏")
		return
	var nick = nick_edit.text.strip_edges()
	if nick == "":
		printerr("用户昵称为空!")
		return
	#start game msg
	Global.start_game.rpc_id(1, multiplayer.get_unique_id(), nick)



func on_game_started(users):
	login_panel.hide()
	var uid = multiplayer.get_unique_id()

	for i in range(users.size()):
		var lb := Label.new()
		lb.add_theme_font_size_override("font_size", 20)
		if uid == users[i].uid:
			lb.add_theme_color_override("font_color", Color.PALE_GREEN)
			Global.nick = users[i].nick
		lb.text = users[i].nick
		user_list_container.add_child(lb)


func on_round_started(uid, answer, tip):
	tip_label.text = answer + " " + tip
	Global.cur_round_uid = uid
	if Global.is_my_round():
		pen_container.show()
		send_msg_btn.disabled = true
	else:
		pen_container.hide()
		send_msg_btn.disabled = false



func _on_send_msg_btn_pressed() -> void:
	if msg_edit.text.strip_edges() == "":
		return
	Global.add_chat_msg.rpc(Global.nick, msg_edit.text)
	msg_edit.text = ""


func on_chat_msg(msg):
	var lb = Label.new()
	lb.add_theme_font_size_override("font_size", 20)
	lb.add_theme_color_override("font_color", Color.YELLOW)
	lb.text = msg
	msg_container.add_child(lb)
