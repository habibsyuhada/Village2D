extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var half_tile_vector = Vector2(8, 8)
var full_tile = 16

onready var world_tile = get_node_or_null("/root/World/Navigation2D/Level1")
onready var world_tile_lv2 = get_node_or_null("/root/World/Navigation2D/Level2")
onready var world_tile_lv3 = get_node_or_null("/root/World/Navigation2D/Level3")
onready var indicator_player = get_node_or_null("/root/World/Indicator")
onready var transition_background = get_node_or_null('/root/TransitionBackground/TransitionBackground/AnimationPlayer')

var player = {
	"item_index_used" : 1,
	"map_file" : '',
}
var inventory = {}
var save_path = "user://file2.save"
var current_scene = null
var map_dynamic = {}
var tile_dynamic = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	transition_background.play("Fade")
	randomize()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
#	first_setup()

func new_games_process():
	var file = File.new()
	if file.file_exists(save_path):
		var dir = Directory.new()
		dir.remove(save_path)
	for i in 18:
		inventory[(i+1)] = {
			"item_id": null,
			"item_qty": 0,
		}
	var temp_slot = {}
	for i in 18:
		temp_slot[(i+1)] = {
			"item_id": null,
			"item_qty": 0,
		}
	temp_slot[1] = {
		"item_id": "hoe",
		"item_qty": 1,
	}
	temp_slot[2] = {
		"item_id": "watercan",
		"item_qty": 1,
	}
	temp_slot[3] = {
		"item_id": "wortelseed",
		"item_qty": 1,
	}
	map_dynamic = {
		"farm" : [
			{
				"filename" : "res://scene/characters/Player.tscn",
				"parent" : "/root/World",
				"cell_pos" : Vector2(0, 0),
			},{
				"filename" : "res://scene/objects/Chest.tscn",
				"parent" : "/root/World",
				"cell_pos" : Vector2(3, 3),
				"slot" : temp_slot,
			}
		]
	}
#	yield(goto_scene("res://scene/maps/World.tscn"), "completed")
	goto_scene("res://scene/maps/World.tscn")

func save_data():
	var save_file = {
		"player": player,
		"inventory": inventory,
		"map_dynamic": map_dynamic,
	}
	
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_var(save_file)
	file.close()
	print("GAME FILE SAVED")
	
func load_games_process():
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var save_file = file.get_var()
		file.close()
		player = save_file["player"]
		inventory = save_file["inventory"]
		map_dynamic = save_file["map_dynamic"]
		goto_scene(player["map_file"])
		print("GAME FILE LOADED")

func waits(s):
	var t = Timer.new()
	t.one_shot = true
	self.add_child(t)
	t.start(s)
	yield(t, "timeout")
	t.queue_free()

func update_invetory(data):
	if data.has("key") :
		var form_data = {
			"item_id" : "",
			"item_qty" : null,
		}
		if data.has("item_id") :
			form_data["item_id"] = data["item_id"]
		if data.has("item_qty") :
			form_data["item_qty"] = data["item_qty"]
		
		inventory[data["key"]] = {
			"item_id": form_data["item_id"],
			"item_qty": form_data["item_qty"],
		}
		
func save_inventory_local():
	for member in get_tree().get_nodes_in_group("ItemBox"):
		print(member.name)

func move_indicator(player_pos, direction):
	if(indicator_player):
		var indicator_pos_map = world_tile.world_to_map(player_pos) + direction
		indicator_player.position = world_tile.map_to_world(indicator_pos_map) + half_tile_vector
	else:
		indicator_player = get_node_or_null("/root/World/Indicator")

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:

	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path):
	transition_background.play_backwards("Fade")
	yield(transition_background, "animation_finished")
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)
	world_tile = get_node_or_null("/root/World/Navigation2D/Level1")
	world_tile_lv2 = get_node_or_null("/root/World/Navigation2D/Level2")
	world_tile_lv3 = get_node_or_null("/root/World/Navigation2D/Level3")
	indicator_player = get_node_or_null("/root/World/Indicator")

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	transition_background.play("Fade")
	yield(transition_background, "animation_finished")

func load_dynamic_node(name_var):
	for node_data in map_dynamic[name_var]:
		var new_object = load(node_data["filename"]).instance()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = world_tile.map_to_world(node_data["cell_pos"]) + half_tile_vector
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])
	
	if name_var in tile_dynamic:
		for key in tile_dynamic[name_var].keys():
			var node = get_node_or_null("/root/World/Navigation2D").find_node(key)
			if node:
				pass

func save_dynamic_node(map):
	player["map_file"] = map.get_filename()

	var name_var = map.map_name
	map_dynamic[name_var]  = []
	var save_nodes = get_tree().get_nodes_in_group("Saved Object")
	for node in save_nodes:
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		var node_data = node.call("save")
		map_dynamic[name_var].push_back(node_data)
		
	var nav2d = map.find_node("Navigation2D")
	if nav2d:
		tile_dynamic[name_var]  = {}
		for node in nav2d.get_children():
			tile_dynamic[name_var][node.name] = node.get_used_cells()
	print(tile_dynamic[name_var])
	save_data()
