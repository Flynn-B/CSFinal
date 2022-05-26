extends base_entity

var prev_pos_offset = Vector2(0,0)

#Preload instance of Health Bar
var health_bar = preload("res://Health_Bar.tscn") #Preload Health bar Scene
var ammo_bar = preload("res://Ammo_Bar.tscn")#Preload Ammo Bar Scene

var player_dead = false

var player = {
	"health" : 15, #Health of enemy
	"max_health" : 15, #Full health of enemy
	"time_since_dmg" : 0 #Time passed since taking damage
}

func _ready():
	health_bar() #Creates health bar
	ammo_bar() #Create ammo bar

func health_bar():
	var bar = health_bar.instance()
	add_child(bar)
func ammo_bar():
	var bar = ammo_bar.instance()
	add_child(bar)

func hit(damage): #Called when hit by bullets
	player.health-=damage
	player.time_since_dmg=0

func regen():
	player.time_since_dmg+=1
	if player.time_since_dmg > 300 and player.health < player.max_health: #After three hundred frames (5 seconds) start regening
		player.health += round(player.time_since_dmg/300)
	elif player.health > player.max_health:
		player.health=player.max_health

func weapon():
	#Flips Player_Sprite to face same way gun is
	is_flipped=$Weapon_Land/Sprite.flip_v
	#Records previous pos offset of the weapon to allow for changing
	if prev_pos_offset != Vector2(0,0):
		prev_pos_offset = $Weapon_Land.weapon.pos_offset
	if is_flipped == true:
		$Weapon_Land.weapon.pos_offset=Vector2(prev_pos_offset.x+$Weapon_Land.weapon.pos_offset_flipped.x,prev_pos_offset.y+$Weapon_Land.weapon.pos_offset_flipped.y)
	else:
		$Weapon_Land.weapon.pos_offset=prev_pos_offset
	#print($Weapon_Land/Sprite.flip_v)
	$Weapon_Land.shoot()

func _physics_process(delta):
	
	if Input.is_action_pressed("left"):
		move_left()
	elif Input.is_action_pressed("right"):
		move_right()
	else:
		is_moving = false

		if player.health <= 0:
			$"Death Screen".visible=true
			player_dead = true
			get_parent().get_node("TileMap").hide()
			

	if Input.is_action_pressed("up") and is_on_floor():
		velocity.y = -JUMP_FORCE
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	weapon()
	regen()
