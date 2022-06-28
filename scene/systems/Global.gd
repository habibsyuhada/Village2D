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

var player = {
	"item_index_used" : 1,
}
var inventory = {}
var save_path = "user://file2.save"
var current_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count() - 1)
#	first_setup()

func first_setup():
	for i in 18:
		if i == 0 :
			inventory[(i+1)] = {
				"item_id": "hoe",
				"item_qty": 1,
			}
		elif i == 1 :
			inventory[(i+1)] = {
				"item_id": "watercan",
				"item_qty": 1,
			}
		else:
			inventory[(i+1)] = {
				"item_id": null,
				"item_qty": 0,
			}

func new_games_process():
	var file = File.new()
	if file.file_exists(save_path):
		var dir = Directory.new()
		dir.remove(save_path)
		for i in 18:
			if i == 0 :
				inventory[(i+1)] = {
					"item_id": "hoe",
					"item_qty": 1,
				}
			elif i == 1 :
				inventory[(i+1)] = {
					"item_id": "watercan",
					"item_qty": 1,
				}
			else:
				inventory[(i+1)] = {
					"item_id": null,
					"item_qty": 0,
				}
	goto_scene("res://scene/maps/World.tscn")

func save_data():
	var save_file = {
		"inventory": inventory,
		"dynamic_node": [],
	}
	
	var save_nodes = get_tree().get_nodes_in_group("Saved Object")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")
		save_file["dynamic_node"].push_back(node_data)
	
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_var(save_file)
	file.close()
	print("GAME FILE SAVED")

func load_data():
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var save_file = file.get_var()
		file.close()
		inventory = save_file["inventory"]
		
		# We need to revert the game state so we're not cloning objects
		# during loading. This will vary wildly depending on the needs of a
		# project, so take care with this step.
		# For our example, we will accomplish this by deleting saveable objects.
		var save_nodes = get_tree().get_nodes_in_group("Saved Object")
		for i in save_nodes:
			i.queue_free()
		# Load the file line by line and process that dictionary to restore
		# the object it represents.
		for node_data in save_file["dynamic_node"]:
			# Firstly, we need to create the object and add it to the tree and set its position.
			var new_object = load(node_data["filename"]).instance()
			get_node(node_data["parent"]).add_child(new_object)
			new_object.global_transform = node_data["global_transform"]
			# Now we set the remaining variables.
			for i in node_data.keys():
				if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
					continue
				if i == "grid_cells":
					for cell in node_data[i]:
						new_object.set_cell_item(cell["cell_pos"].x, cell["cell_pos"].y, cell["cell_pos"].z, cell["cell_item"])
					continue
				new_object.set(i, node_data[i])
		
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
	# It is now safe to remove the current scene
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instance()

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	world_tile = get_node_or_null("/root/World/Navigation2D/Level1")
	world_tile_lv2 = get_node_or_null("/root/World/Navigation2D/Level2")
	world_tile_lv3 = get_node_or_null("/root/World/Navigation2D/Level3")
	indicator_player = get_node_or_null("/root/World/Indicator")
