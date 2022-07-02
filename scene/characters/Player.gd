extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 4000
var velocity = Vector2.ZERO
var dir_animation = "Down"
var dir_last = Vector2.DOWN
var state_anim_machine
var isinaction = false
export (PackedScene) var Indicator
export (PackedScene) var Crop

# Called when the node enters the scene tree for the first time.
func _ready():
	state_anim_machine = $AnimationTree.get("parameters/playback")
	var temp_indicator = Indicator.instance()
	temp_indicator.position = position
	$"/root/World".add_child(temp_indicator)
	Global.move_indicator(position, dir_last)
	pass # Replace with function body.

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"cell_pos" : Global.world_tile.world_to_map(position),
	}
	return save_dict

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var direction = Vector2.ZERO
	velocity = Vector2.ZERO
	if Input.is_action_pressed("W"):
		direction = Vector2.UP
	elif Input.is_action_pressed("A"):
		direction = Vector2.LEFT
	elif Input.is_action_pressed("S"):
		direction = Vector2.DOWN
	elif Input.is_action_pressed("D"):
		direction = Vector2.RIGHT
	var cur_speed = speed
	if Input.is_action_just_released("E"):
		var scanned_by_indicator = Global.indicator_player.get_overlapping_bodies()
		var take_item = null
		for body in scanned_by_indicator:
			if body != self:
				take_item = body
		if take_item != null and take_item.has_method("interact"):
			take_item.interact()
#		isinaction = true
	if Input.is_action_just_released("Space"):
		isinaction = true
		if Global.inventory[Global.player["item_index_used"]]["item_id"] == "hoe" :
			state_anim_machine.travel(str("Hoe_" + dir_animation))
		if Global.inventory[Global.player["item_index_used"]]["item_id"] == "watercan" :
			state_anim_machine.travel(str("Watering_" + dir_animation))
		if "seed" in Global.inventory[Global.player["item_index_used"]]["item_id"] :
			state_anim_machine.travel(str("Seed_" + dir_animation))
	if !isinaction:
		velocity = direction.normalized() * cur_speed * delta
		move_and_slide(velocity)
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0 :
				dir_animation = "Right"
			elif velocity.x < 0:
				dir_animation = "Left"
		else:
			if velocity.y > 0 :
				dir_animation = "Down"
			elif velocity.y < 0:
				dir_animation = "Up"
		if velocity != Vector2.ZERO:
			dir_last = direction
			state_anim_machine.travel(str("Walk_" + dir_animation))
	#		$AnimationPlayer.play(str("Walk_" + dir_animation))
			Global.move_indicator(position, dir_last)
		else:
			state_anim_machine.travel(str("Idle_" + dir_animation))
	#		$AnimationPlayer.play(str("Idle_" + dir_animation))

func hoe_process():
	var map_tile = Global.world_tile_lv2.world_to_map(Global.indicator_player.position)
	if(Global.world_tile.get_cell(map_tile.x, map_tile.y) in [0] and Global.world_tile_lv2.get_cell(map_tile.x, map_tile.y) in [-1]):
		Global.world_tile_lv2.set_cell(map_tile.x, map_tile.y, 1)
		Global.world_tile_lv2.update_bitmask_area (map_tile)
	isinaction = false

func watering_process():
	var map_tile = Global.world_tile_lv3.world_to_map(Global.indicator_player.position)
	if(Global.world_tile_lv2.get_cell(map_tile.x, map_tile.y) in [1] and Global.world_tile_lv3.get_cell(map_tile.x, map_tile.y) in [-1]):
		Global.world_tile_lv3.set_cell(map_tile.x, map_tile.y, 2)
		Global.world_tile_lv3.update_bitmask_area (map_tile)
	isinaction = false

func seeding_process():
	var map_tile = Global.world_tile_lv3.world_to_map(Global.indicator_player.position)
	if(Global.world_tile_lv2.get_cell(map_tile.x, map_tile.y) in [1] and Global.world_tile_lv3.get_cell(map_tile.x, map_tile.y) in [2]):
		pass
	isinaction = false
