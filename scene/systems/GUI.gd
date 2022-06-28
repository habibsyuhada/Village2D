extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (PackedScene) var HUD
export (PackedScene) var Menu
export (PackedScene) var ItemBox
export (PackedScene) var Chest
var itembox_placement = Vector2(64, 64)
var itembox_spacing = 16
var storage = null
var slot_storage = {}


# Called when the node enters the scene tree for the first time.
func _ready():
#	open_hud()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func toogle_menu(status):
	if status == true:
		var menu = Menu.instance()
		add_child(menu)
		setup_inventory()
	else:
		var menu = get_node_or_null("Menu")
		if menu != null:
			menu.queue_free()
			
func toogle_chest(status, slot = {} ):
	slot_storage = slot
	if status == true:
		var chest = Chest.instance()
		add_child(chest)
		if slot.size() > 0 :
			setup_storage_item(slot)
	else:
		var menu = get_node_or_null("Storage_Item")
		if menu != null:
			menu.queue_free()
		
func toogle_hud(status):
	if status == true:
		var hud = HUD.instance()
		add_child(hud)
		setup_quick_access_inventory()
	else: 
		var hud = get_node_or_null("HUD")
		if hud != null:
			hud.queue_free()

func setup_inventory():
	if get_node_or_null("Menu") != null:
		var itembox_data = ItemBox.instance()
		var no = 0
		for v in 3:
			var itembox_position = itembox_placement
			itembox_position.y = itembox_placement.y + v*itembox_data.rect_size.y + v*itembox_spacing
			for h in 6:
				no += 1
				var itembox = ItemBox.instance()
				itembox.name = "itembox"+str(no)
				itembox_position.x = itembox_placement.x + h*itembox.rect_size.x + h*itembox_spacing
				itembox.rect_position = itembox_position
				itembox.itembox_index = no
				itembox.isdragable = true
				itembox.item_id = Global.inventory[no]["item_id"]
				itembox.item_qty = Global.inventory[no]["item_qty"]
				$Menu/Inventory.add_child(itembox)
		itembox_data.queue_free()
		
func setup_storage_item(slot):
	if get_node_or_null("Storage_Item") != null:
		var itembox_data = ItemBox.instance()
		var no = 0
		$Storage_Item/HBoxContainer/Chest.set("custom_constants/separation", itembox_spacing)
		for v in 3:
			var Hbox_ref = HBoxContainer.new()
			$Storage_Item/HBoxContainer/Chest.add_child(Hbox_ref)
			Hbox_ref.set("custom_constants/separation", itembox_spacing)
			Hbox_ref.set("alignment", 1)
			var itembox_position = itembox_placement
			#itembox_position.y = itembox_placement.y + v*itembox_data.rect_size.y + v*itembox_spacing
			for h in 6:
				no += 1
				var itembox = ItemBox.instance()
				itembox.name = "itembox"+str(no)
				#itembox_position.x = itembox_placement.x + h*itembox.rect_size.x + h*itembox_spacing
				itembox.rect_position = itembox_position
				itembox.itembox_index = no
				itembox.isdragable = true
				itembox.item_id = slot[no]["item_id"]
				itembox.item_qty = slot[no]["item_qty"]
				itembox.category = "Storage"
				Hbox_ref.add_child(itembox)
		itembox_data.queue_free()
		
	if get_node_or_null("Storage_Item") != null:
		var itembox_data = ItemBox.instance()
		var no = 0
		$Storage_Item/HBoxContainer/Inventory.set("custom_constants/separation", itembox_spacing)
		for v in 3:
			var Hbox_ref = HBoxContainer.new()
			$Storage_Item/HBoxContainer/Inventory.add_child(Hbox_ref)
			Hbox_ref.set("custom_constants/separation", itembox_spacing)
			Hbox_ref.set("alignment", 1)
			var itembox_position = itembox_placement
			#itembox_position.y = itembox_placement.y + v*itembox_data.rect_size.y + v*itembox_spacing
			for h in 6:
				no += 1
				var itembox = ItemBox.instance()
				itembox.name = "itembox"+str(no)
				#itembox_position.x = itembox_placement.x + h*itembox.rect_size.x + h*itembox_spacing
				itembox.rect_position = itembox_position
				itembox.itembox_index = no
				itembox.isdragable = true
				itembox.item_id = Global.inventory[no]["item_id"]
				itembox.item_qty = Global.inventory[no]["item_qty"]
				Hbox_ref.add_child(itembox)
		itembox_data.queue_free()
		
func setup_quick_access_inventory():
	itembox_placement = Vector2(16, 16)
	if get_node_or_null("HUD") != null:
		var itembox_data = ItemBox.instance()
		var no = 0
		for v in 1:
			var itembox_position = itembox_placement
			itembox_position.y = itembox_placement.y + v*itembox_data.rect_size.y + v*itembox_spacing
			for h in 6:
				no += 1
				var itembox = ItemBox.instance()
				itembox.name = "itembox"+str(no)
				itembox_position.x = itembox_placement.x + h*itembox.rect_size.x + h*itembox_spacing
				itembox.rect_position = itembox_position
				itembox.itembox_index = no
				itembox.isshowplayerused = true
				itembox.item_id = Global.inventory[no]["item_id"]
				itembox.item_qty = Global.inventory[no]["item_qty"]
				$HUD/Quick_Access_Item.add_child(itembox)
		itembox_data.queue_free()

func update_storage(data):
	if data.has("key") :
		var form_data = {
			"item_id" : "",
			"item_qty" : null,
		}
		if data.has("item_id") :
			form_data["item_id"] = data["item_id"]
		if data.has("item_qty") :
			form_data["item_qty"] = data["item_qty"]
		
		slot_storage[data["key"]] = {
			"item_id": form_data["item_id"],
			"item_qty": form_data["item_qty"],
		}

func open_menu():
	toogle_hud(false)
	toogle_menu(true)
	toogle_chest(false)
	$Backgroud.visible = true

func open_hud():
	toogle_hud(true)
	toogle_menu(false)
	toogle_chest(false)
	$Backgroud.visible = false
	
func open_chest(action_storage):
	storage = action_storage
	toogle_hud(false)
	toogle_menu(false)
	toogle_chest(true, storage.slot)
	$Backgroud.visible = true

func close_chest():
	storage.slot = slot_storage
	storage = null
	slot_storage = {}
