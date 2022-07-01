extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Close_Menu_Button_button_up():
	GUI.open_hud()


func _on_Save_Menu_Button_button_up():
	var map = get_node_or_null("/root/World")
	if map:
		Global.save_dynamic_node(map)
