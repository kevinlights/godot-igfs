extends Spatial



# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "PJT" }

var config = ConfigFile.new()
var err = config.load("res://settings.cfg")

var HOST = config.get_value("multiplayer","is_host",true)

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
		peer.create_client(config.get_value("multiplayer","address","127.0.0.1"), config.get_value("multiplayer","port",5000))
		get_tree().set_network_peer(peer)
	print("Peer: " + str(get_tree().get_network_peer()))
	print("Is server: " + str(get_tree().is_network_server()))
	add_connections()
	apply_settings()

	yield(get_tree().create_timer(5), "timeout")
	print("detected ship parameter:" + str( get_node("SpaceShip").ship))
	if get_node("SpaceShip").ship != 0:
		get_node("SpaceShip").ship = 0;
		# get_node("SpaceShip").load_ship_type(0)
		EventManager.emit("ship_type_change",0)

func add_connections():
	get_tree().connect("network_peer_connected", self, "player_connected")
	get_tree().connect("network_peer_disconnected", self, "player_disconnected")
	get_tree().connect("connected_to_server", self, "connected_ok")
	get_tree().connect("connection_failed", self, "connected_fail")
	get_tree().connect("server_disconnected", self, "server_disconnected")
	get_tree().connect("peer_connected", self, "peer_connected")
	get_node("SpaceShip").connect("position",self,"update_position_local")

func apply_settings():
	#GlowHDR
	var GlowHDR = config.get_value("settings","GlowHDR",false);
	var enviroment;
	if GlowHDR == true:
		enviroment = ResourceLoader.load("res://Scenes/Game/Environments/GlowAndAutoExposure.tres");
	else:
		enviroment = ResourceLoader.load("res://Scenes/Game/Environments/Performance.tres");
	get_node("WorldEnvironment").set_environment(enviroment)

func player_connected(id):
	print("Player connected, id: " + str(id))

func player_disconnected(id):
	print("Player disconnected, id: " + str(id))

	rpc("unregister_player", id)
	unregister_player(id)

func connected_ok():
	print("Connected to server")
	# Only called on clients, not server. Send my ID and info to all the other peers.
	yield(get_tree().create_timer(5), "timeout")
	rpc("register_player", get_tree().get_network_unique_id(), my_info)
	# rpc_id(1, "register_player", get_tree().get_network_unique_id(), my_info)

func connected_fail():
	print("Failed to connect to server")
	get_tree().set_network_peer(null)
	get_tree().change_scene("res://Scenes/Home/Home.tscn")

func server_disconnected():
	print("Disconnected from server")
	get_tree().set_network_peer(null)
	get_tree().change_scene("res://Scenes/Home/Home.tscn")

func update_position_local(position):
	rpc("update_position",get_tree().get_network_unique_id(), position)
	
# func _on_message(message):
# 	print("message: " + message)
# 	get_node("Message").text = message
# 	print(get_node("Message").text)

remote func register_player(id, info):
	# Store the info
	print("Registering player, id: " + str(id))
	if id != get_tree().get_network_unique_id():
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

	if get_node("SpaceShips/" + str(id)):
		get_node("SpaceShips/" + str(id)).queue_free()

	print("Players: " + str(player_info))

remote func update_position(id,position):
	# print("Update position of " + str(id) + ": " + str(position))
	if has_node("SpaceShips/" + str(id)):
		get_node("SpaceShips/" + str(id)).translation = position.coords
		get_node("SpaceShips/" + str(id)).set_rotation(position.rotation)


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
