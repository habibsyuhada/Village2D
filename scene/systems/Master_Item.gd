extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var master_item = {null: null}
var master_crop = {null: null}

# Called when the node enters the scene tree for the first time.
func _ready():
	add_master_item()
	add_master_crop()

func add_master_crop():
	add_data_crop({
		"key": "carrot",
		"name": "Carrot",
		"sprite_plant" : "carrot",
		"consumable" : 1,
		"days_grow" : 4,
		"price" : 25,
		"sell_price" : 40,
	})

func add_master_item():
	add_data_item({
		"key": "hoe",
		"name": "Hoe",
		"sprite": "res://assets/tools/Hoe.png",
		"consumable" : 0,
	})
	add_data_item({
		"key": "watercan",
		"name": "Water Can",
		"sprite": "res://assets/tools/Water Can.png",
		"consumable" : 0,
	})
	add_data_item({
		"key": "wortelseed",
		"name": "Wortel Seed",
		"sprite": "res://assets/tools/Wortel Seed.png",
		"consumable" : 1,
	})


func add_data_item(data):
	if data.has("key") :
		var form_data = {
			"name" : "",
			"sprite" : null,
			"consumable" : 0,
		}
		for form in form_data.keys():
			if data.has(form) :
				form_data[form] = data[form]
		
		master_item[data["key"]] = {}
		for form in form_data.keys():
			master_item[data["key"]][form] = form_data[form]

func add_data_crop(data):
	if data.has("key") :
		var form_data = {
			"name" : "",
			"sprite_plant" : "",
			"consumable" : 0,
			"days_grow" : 0,
			"price" : 0,
			"sell_price" : 0,
		}
		for form in form_data.keys():
			if data.has(form) :
				form_data[form] = data[form]
		
		master_item[data["key"]] = {}
		for form in form_data.keys():
			master_item[data["key"]][form] = form_data[form]
