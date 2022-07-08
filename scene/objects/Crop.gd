extends StaticBody2D

var time_start = 0
var time_now = 0
var id_crop = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	time_now = OS.get_unix_time()
	var time_elapsed = time_now - time_start
	var total_frame = $AnimatedSprite.frames.get_frame_count($AnimatedSprite.animation) - 1
	var anim_per_grow = MasterItem.master_crop[id_crop]['second_full_grow'] / total_frame
	print(time_elapsed)
	print(floor(time_elapsed / anim_per_grow))
	if time_elapsed >= MasterItem.master_crop[id_crop]['second_full_grow'] and $AnimatedSprite.frame != total_frame:
		$AnimatedSprite.frame = total_frame
	elif  $AnimatedSprite.frame != floor(time_elapsed / anim_per_grow):
		$AnimatedSprite.frame = floor($AnimatedSprite.frame/total_frame)
	pass

func save():
	var save_dict = {
		"filename" : get_filename(),
		"parent" : get_parent().get_path(),
		"cell_pos" : Global.world_tile.world_to_map(position),
		"time_start" : time_start,
		"id_crop" : id_crop,
	}
	return save_dict
