extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var master_item = {null: null}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_data({
		"key": "hoe",
		"name": "Hoe",
		"sprite": "res://assets/tools/Hoe.png",
	})
	add_data({
		"key": "watercan",
		"name": "Water Can",
		"sprite": "res://assets/tools/Water Can.png",
	})


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func add_data(data):
	if data.has("key") :
		var form_data = {
			"name" : "",
			"sprite" : null,
		}
		if data.has("name") :
			form_data["name"] = data["name"]
		if data.has("sprite") :
			form_data["sprite"] = data["sprite"]
		
		master_item[data["key"]] = {
			"name": form_data["name"],
			"sprite": form_data["sprite"],
		}
