extends Control

@onready var network_manager: Control = $NetworkManager

@export var is_server = false

const GamePlayScene := preload("res://game_play.tscn")

func _ready() -> void:
	if is_server:
		var server := Server.new()
		network_manager.add_child(server)
		Global.server = server
	else:
		var client := Client.new()
		network_manager.add_child(client)
		add_child(GamePlayScene.instantiate())
