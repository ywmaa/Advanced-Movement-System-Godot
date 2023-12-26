extends Node
class_name LevelManager
## This is responsible for spawning the player, managing the level itself
## and also includes simple UI and network connection for quick testing.

@export_group("Test")
## It will show a network connection UI and allow you to spawn a test player character.
## Should be disabled if you have a main manu that will handle player connection, level and player spawning.
@export var enable_testing : bool = true
## The test player character that is going to be spawned 
@export var player_character = preload("res://AMSG_Examples/Player/Player.tscn")
@export var testing_ui = preload("res://AMSG_Examples/UI/test_ui.tscn")
@export_group("Network")
## Default port to connect in testing
@export var port := 8313
## Default IP Address to connect in testing
@export var ip_address_to_connect := "localhost"
@export_group("Spawn")
@export var spawn_locations : Array[Node3D]

var singleplayer := false 
var is_the_server_a_player := true #if it is peer to peer the server will also have a playable character 
# Called when the node enters the scene tree for the first time.

var spawned_test_ui : Control
func _enter_tree():
	# Start the server if Godot passed the "--server" argument,
	# and start the client if Godot passed the "--client" argument.
	if "--listen_server" in OS.get_cmdline_args():
		_on_server_pressed()
	elif "--client" in OS.get_cmdline_args():
		_on_client_pressed()
	elif "--server" in OS.get_cmdline_args():
		_on_d_server_pressed()
	
	if enable_testing:
		spawned_test_ui = testing_ui.instantiate()
		add_child(spawned_test_ui)
		spawned_test_ui.listen_server_button.connect("pressed", _on_server_pressed)
		spawned_test_ui.d_server_button.connect("pressed", _on_d_server_pressed)
		spawned_test_ui.client_button.connect("pressed", _on_client_pressed)
		spawned_test_ui.single_player_button.connect("pressed", _on_singleplayer_pressed)
		spawned_test_ui.main_menu_button.connect("pressed", _on_main_menu_pressed)
		spawned_test_ui.ip_textbox.connect("text_changed", _on_ip_address_text_changed)

func _on_server_pressed():
	is_the_server_a_player = true
	start_network(true)
	get_window().title = "Server"

func _on_d_server_pressed():
	is_the_server_a_player = false
	start_network(true)
	get_window().title = "Dedicated Server"

func _on_client_pressed():
	start_network(false)
	get_window().title = "Client"


func _on_singleplayer_pressed():
	single_player()
	get_window().title = "Singleplayer/Offline"
	

func _on_main_menu_pressed():
	spawned_test_ui.listen_server_button.visible = true
	spawned_test_ui.d_server_button.visible = true
	spawned_test_ui.client_button.visible = true
	spawned_test_ui.single_player_button.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if singleplayer:
		for Spawn in spawn_locations:
			for c in Spawn.get_children():
				c.queue_free()
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
	if spawned_test_ui.ip_textbox.text == "":
		ip_address_to_connect = "localhost"
	else:
		ip_address_to_connect = spawned_test_ui.ip_textbox.text




######## Basic Network Handeling for testing ########



func single_player():
	singleplayer = true
	spawned_test_ui.listen_server_button.visible = false
	spawned_test_ui.d_server_button.visible = false
	spawned_test_ui.client_button.visible = false
	spawned_test_ui.single_player_button.visible = false
	var p = player_character.instantiate()
	spawn_locations.pick_random().add_child(p)


func start_network(server:bool) -> void:
	singleplayer = false
	spawned_test_ui.listen_server_button.visible = false
	spawned_test_ui.d_server_button.visible = false
	spawned_test_ui.client_button.visible = false
	spawned_test_ui.single_player_button.visible = false
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
	var p = player_character.instantiate()
	p.set_name(str(id))
	spawn_locations.pick_random().add_child(p)
#	p.top_level = true
	
func destroy_player(id: int) -> void:
	find_child(str(id),true,false).queue_free()




