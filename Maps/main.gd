extends Node

@export var PlayerCharacter = preload("res://Player/Player.tscn")
@export var peer_to_peer := true #is it is peer to peer the server will also have a playable character 
# Called when the node enters the scene tree for the first time.
func _enter_tree():
	# Start the server if Godot is passed the "--server" argument,
	# and start the client if Godot is passed the "--client" argument.
	if "--server" in OS.get_cmdline_args():
		start_network(true)
	elif "--client" in OS.get_cmdline_args():
		start_network(false)
func single_player():
	$Server.visible = false
	$Client.visible = false
	$Singleplayer.visible = false
	var p = PlayerCharacter.instantiate()
	$PlayerSpawnLocation.add_child(p)
	
func start_network(server:bool) -> void:
	$Server.visible = false
	$Client.visible = false
	$Singleplayer.visible = false
	var peer = ENetMultiplayerPeer.new()
	
	if server:
		
		#listen to peer connections, and create new player for them
		multiplayer.peer_connected.connect(self.create_player)
		#listen to peer disconnections, and destroy their players
		multiplayer.peer_disconnected.connect(self.destroy_player)
		
		peer.create_server(8313)
#		if peer_to_peer:
#			create_player(get_multiplayer_authority())
		print("server listening on localhost 8313")
	else:
		peer.create_client("localhost",8313)
	
	multiplayer.set_multiplayer_peer(peer)
func create_player(id: int) -> void:
	var p = PlayerCharacter.instantiate()
	p.name = str(id)
	$PlayerSpawnLocation.add_child(p)
	
func destroy_player(id: int) -> void:
	$PlayerSpawnLocation.get_node(str(id)).queue_free()
	$Server.visible = true
	$Client.visible = true
	$Singleplayer.visible = true



func _on_server_pressed():
	start_network(true)


func _on_client_pressed():
	start_network(false)


func _on_singleplayer_pressed():
	single_player()
