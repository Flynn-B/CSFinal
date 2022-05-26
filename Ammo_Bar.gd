extends Node2D

var length = 12
var bar_distance = 15

var ammo_flash_timer = 0 #Timer for flash
var ammo_flash_time = 5 #Time to flash

# Called when the node enters the scene tree for the first time.
func _ready():
	$Bar_Boundries.rect_size = Vector2(3,length+2)
	$Missing_Ammo.rect_size = Vector2(1,length)
	$Ammo.rect_size = Vector2(1,length)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Checking if parent has health and max_health to avoid crashes
	#if "enemy".has('health') in get_parent() and enemy.has('max_health') in get_parent():
	if "enemy" in get_parent():
		var ammo_percentage = float(get_parent().get_node("Weapon_Land").weapon.current_ammo)/float(get_parent().get_node("Weapon_Land").weapon.ammo_round)
		$Ammo.rect_size = Vector2(1,length*ammo_percentage)
		#Resetting global_rotation to make health bar be upright
		global_rotation=PI/2
		#Setting health_bar position above enemy
		global_position=get_parent().global_position+Vector2(length/2,-bar_distance)
		if get_parent().get_node("Weapon_Land").weapon.reload_timer > 0:
			$Ammo.color=Color(0.86,0.24,0.26,1)
		else:
			$Ammo.color=Color(0.48,0.74,0.92,1)
	elif "player" in get_parent():
		var ammo_percentage = float(get_parent().get_node("Weapon_Land").weapon.current_ammo)/float(get_parent().get_node("Weapon_Land").weapon.ammo_round)
		$Ammo.rect_size = Vector2(1,length*ammo_percentage)
		#Resetting global_rotation to make health bar be upright
		global_rotation=PI/2
		#Setting health_bar position above enemy
		global_position=get_parent().global_position+Vector2(length/2,-bar_distance)
		if get_parent().get_node("Weapon_Land").weapon.reload_timer > 0:
			$Ammo.color=Color(0.86,0.24,0.26,1)
		else:
			$Ammo.color=Color(0.48,0.74,0.92,1)
		if get_parent().player_dead:
			queue_free()
