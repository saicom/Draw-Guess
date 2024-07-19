class_name Client
extends Node


const PORT = 8888
var peer = ENetMultiplayerPeer.new()


func _ready() -> void:
	var err := peer.create_client("127.0.0.1", PORT)
	if err != OK:
		printerr("create client failed:", err)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(on_connected_to_server)


func on_connected_to_server():
	print("connected to server")
	Global.is_connect_server = true
