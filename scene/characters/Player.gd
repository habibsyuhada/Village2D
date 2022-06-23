extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 4000
var velocity = Vector2.ZERO
var dir_animation = "Down"
var dir_last = Vector2.DOWN
export (PackedScene) var Indicator

# Called when the node enters the scene tree for the first time.
func _ready():
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
	if Input.is_action_just_released("Space"):
		walling(dir_last)
	var cur_speed = speed
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
#		$AnimationPlayer.play(str("Walk_" + dir_animation))
	else:
#		$AnimationPlayer.play(str("Idle_" + dir_animation))
		pass

func walling(direction):
	var indicator = Indicator.instance()
	indicator.position = Global.world_tile.map_to_world(Global.world_tile.world_to_map(position)) + Global.half_tile_vector
	indicator.velocity = direction
	indicator.caster = self
	get_node("/root/World").add_child(indicator)
