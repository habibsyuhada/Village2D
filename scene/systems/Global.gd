extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var half_tile_vector = Vector2(8, 8)
var full_tile = 16

onready var world_tile = get_node_or_null("/root/World/Navigation2D/Level1")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func waits(s):
	var t = Timer.new()
	t.one_shot = true
	self.add_child(t)
	t.start(s)
	yield(t, "timeout")
	t.queue_free()
