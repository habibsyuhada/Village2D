extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var first_setup = false;
var map_name = "farm"

# Called when the node enters the scene tree for the first time.
func _ready():
#	Global.load_dynamic_node("farm")
#
#	$Camera2D.add_target($Player)
#	GUI.open_hud()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !first_setup:
		if Global.world_tile:
			first_setup = true
			Global.load_dynamic_node(map_name)
			$Camera2D.add_target($Player)
			GUI.open_hud()
