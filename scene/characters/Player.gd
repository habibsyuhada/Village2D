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

# Called when the node enters the scene tree for the first time.
func _ready():
	state_anim_machine = $AnimationTree.get("parameters/playback")
	pass # Replace with function body.


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
	if Input.is_action_just_released("Space"):
		isinaction = true
		state_anim_machine.travel(str("Hoe_" + dir_animation))
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
	if(Global.world_tile_lv2.get_cell(map_tile.x, map_tile.y) in [-1]):
		Global.world_tile_lv2.set_cell(map_tile.x, map_tile.y, 1)
		Global.world_tile_lv2.update_bitmask_area (map_tile)
	isinaction = false
