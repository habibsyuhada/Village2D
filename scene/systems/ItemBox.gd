extends ColorRect

var item_id = null
var item_qty = 0

var itembox_index = 0
var category = "Invetory"

var can_drag = false
var grabbed_offset = Vector2()
var default_position = Vector2()

var isdragable = false
var isshowplayerused = false

func _ready():
	default_position = $Sprite.position

func _on_ItemBox_gui_input(event):
	if event is InputEventMouseButton and isshowplayerused:
		Global.player["item_index_used"] = itembox_index
	
	if event is InputEventMouseButton and item_id != null and isdragable:
		can_drag = event.pressed
		grabbed_offset = $Sprite.position - get_global_mouse_position()
		if !event.pressed :
			var closest_distance = null
			var closest_itembox = null
			for member in get_tree().get_nodes_in_group("ItemBox"):
				if member != self :
					var distance = ($Sprite.get_global_transform().origin - member.get_node("Sprite").get_global_transform().origin).length()
					if distance < rect_size.x / 2 :
						if closest_distance == null or closest_distance > distance :
							closest_distance = distance
							closest_itembox = member
			if closest_itembox != null :
				var old_item_id = item_id
				item_id = closest_itembox.item_id
				closest_itembox.item_id = old_item_id
				
				var old_item_qty = item_qty
				item_qty = closest_itembox.item_qty
				closest_itembox.item_qty = old_item_qty
				
				if category == "Invetory" :
					Global.update_invetory({
						"key": itembox_index,
						"item_id": item_id,
						"item_qty": item_qty,
					})
				elif category == "Storage" :
					GUI.update_storage({
						"key": itembox_index,
						"item_id": item_id,
						"item_qty": item_qty,
					})
				if closest_itembox.category == "Invetory" :
					Global.update_invetory({
						"key": closest_itembox.itembox_index,
						"item_id": closest_itembox.item_id,
						"item_qty": closest_itembox.item_qty,
					})
				elif closest_itembox.category == "Storage" :
					GUI.update_storage({
						"key": closest_itembox.itembox_index,
						"item_id": closest_itembox.item_id,
						"item_qty": closest_itembox.item_qty,
					})
			$Sprite.position = default_position

func _process(delta):
	var sprite_texture = null
	if MasterItem.master_item[item_id] != null :
		sprite_texture = MasterItem.master_item[item_id]["sprite"]
	if $Sprite.texture != null :
		if $Sprite.texture.resource_path != sprite_texture :
			if sprite_texture != null :
				$Sprite.texture = load(sprite_texture)
			else :
				$Sprite.texture = null
	else :
		if sprite_texture != null :
			$Sprite.texture = load(sprite_texture)
	if $Sprite/Label.text != str(item_qty):
		$Sprite/Label.text = str(item_qty)
		if item_qty > 1:
			$Sprite/Label.visible = true
		else:
			$Sprite/Label.visible = false
	
	if isshowplayerused:
		var color_actual = Color("#ffffff")
		if itembox_index == Global.player["item_index_used"]:
			color_actual = Color("#b2eeee")
		if color_actual != color:
			color = color_actual
			
	if Input.is_mouse_button_pressed(BUTTON_LEFT) and can_drag and isdragable:
		$Sprite.position = get_global_mouse_position() + grabbed_offset

