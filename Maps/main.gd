extends Node
@export var port := 8313
@export var ip_address_to_connect := "localhost"
var singleplayer := false 
@export var PlayerCharacter = preload("res://Player/Player.tscn")
var is_the_server_a_player := true #if it is peer to peer the server will also have a playable character 
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	# Start the server if Godot passed the "--server" argument,
	# and start the client if Godot passed the "--client" argument.
	if "--listen_server" in OS.get_cmdline_args():
		_on_server_pressed()
	elif "--client" in OS.get_cmdline_args():
		_on_client_pressed()
	elif "--server" in OS.get_cmdline_args():
		_on_d_server_pressed()
func single_player():
	singleplayer = true
	$ListenServer.visible = false
	$DServer.visible = false
	$Client.visible = false
	$Singleplayer.visible = false
	var p = PlayerCharacter.instantiate()
	$PlayerSpawnLocation.add_child(p)
	
func start_network(server:bool) -> void:
	singleplayer = false
	$ListenServer.visible = false
	$DServer.visible = false
	$Client.visible = false
	$Singleplayer.visible = false
	var peer = ENetMultiplayerPeer.new()
	#on server disconnected
	multiplayer.server_disconnected.connect(self.server_disconnected)
	#on connection failed
	multiplayer.connection_failed.connect(self.connection_failed)
	if server:
		
		#listen to peer connections, and create new player for them
		multiplayer.peer_connected.connect(self.player_joined)
		#listen to peer disconnections, and destroy their players
		multiplayer.peer_disconnected.connect(self.player_disconnected)

		peer.create_server(port)
		multiplayer.set_multiplayer_peer(peer)
		if is_the_server_a_player:
			create_player(1)
		print("server listening on %s" %IP.get_local_addresses()[0])
	else:
		peer.create_client(ip_address_to_connect,port)
		multiplayer.set_multiplayer_peer(peer)


func player_joined(id:int):
	create_player(id)
func player_disconnected(id:int):
	destroy_player(id)
func server_disconnected():
	_on_main_menu_pressed()
func connection_failed():
	print("connection failed")




func create_player(id: int) -> void:
	var p = PlayerCharacter.instantiate()
	p.name = str(id)
	$PlayerSpawnLocation.add_child(p)
#	p.top_level = true
	
func destroy_player(id: int) -> void:
	$PlayerSpawnLocation.get_node(str(id)).queue_free()
	


func _on_server_pressed():
	is_the_server_a_player = true
	start_network(true)

func _on_d_server_pressed():
	is_the_server_a_player = false
	start_network(true)

func _on_client_pressed():
	start_network(false)


func _on_singleplayer_pressed():
	single_player()



func _on_main_menu_pressed():
	$ListenServer.visible = true
	$DServer.visible = true
	$Client.visible = true
	$Singleplayer.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if singleplayer:
		for i in $PlayerSpawnLocation.get_child_count():
			$PlayerSpawnLocation.get_child(i).queue_free()
	else:
		if multiplayer.is_server():
			for p in multiplayer.get_peers():
				destroy_player(p)
			if is_the_server_a_player:
				destroy_player(1)
		multiplayer.set_multiplayer_peer(null)
		

func _input(event):
	if Input.is_action_just_pressed("exit"):
		_on_main_menu_pressed()


func _on_ip_address_text_changed():
	if $Client/IP_address.text == "":
		ip_address_to_connect = "localhost"
	else:
		ip_address_to_connect = $Client/IP_address.text



