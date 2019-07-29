extends Spatial


var HOST = true

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "PJT" }

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if HOST:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_server(5000, 10)
		get_tree().set_network_peer(peer)
	else:
		var peer = NetworkedMultiplayerENet.new()
		peer.create_client("127.0.0.1", 5000)
		get_tree().set_network_peer(peer)
	print("Peer: " + str(get_tree().get_network_peer()))
	print("Is server: " + str(get_tree().is_network_server()))
	add_connections()

func add_connections():
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("connection_failed", self, "connected_fail")
	get_tree().connect("server_disconnected", self, "server_disconnected")

func player_connected(id):
	print("Player connected, id: " + str(id))

func player_disconnected(id):
	print("Player disconnected, id: " + str(id))

	rpc("unregister_player", id)
	unregister_player(id)

func connected_ok():
	print("Connected to server")
	# Only called on clients, not server. Send my ID and info to all the other peers.
	rpc("register_player", get_tree().get_network_unique_id(), my_info)

func connected_fail():
	print("Failed to connect to server")

func server_disconnected():
	print("Disconnected from server")
	
# func _on_message(message):
# 	print("message: " + message)
# 	get_node("Message").text = message
# 	print(get_node("Message").text)

remote func register_player(id, info):
	# Store the info
	player_info[id] = info
	var player = preload("res://Components/SpaceShipPuppet/SpaceShipPuppet.tscn").instance()
	# var player = CSGBox.new()
	player.set_name(str(id))
	player.set_network_master(id) # Will be explained later
	get_node("SpaceShips").add_child(player)
	# If I'm the server, let the new guy know about existing players.
	if get_tree().is_network_server():
		# Send my info to new player
		rpc_id(id, "register_player", 1, my_info)
		# Send the info of existing players
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])

	print("Players: " + str(player_info))

remote func unregister_player(id):
	# Store the info
	player_info.erase(id)

	get_node("SpaceShips/" + str(id)).queue_free()

	print("Players: " + str(player_info))


# remote func pre_configure_game():
# 	var selfPeerID = get_tree().get_network_unique_id()

# 	# Load my player
# 	get_node("SpaceShip").set_network_master(selfPeerID)
# 	# get_node("SpaceShip").set_name(str(selfPeerID))

# 	# Load other players
# 	for p in player_info:
# 		var player = preload("res://Components/SpaceShip/SpaceShip.tscn").instance()
# 		player.set_name(str(p))
# 		player.set_network_master(p) # Will be explained later
# 		get_node("SpaceShips").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# rpc_id(1, "done_preconfiguring", selfPeerID)
