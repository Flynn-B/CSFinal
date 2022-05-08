extends Area2D

#Preload instances of scenes
var projectile = preload("res://Projectile.tscn") #Preload Projectile Scene

var user = 'player'
var target = Vector2()

var shoot = false

var weapon_type = ''

var weapon = {
	"projectile_type" : "",
	"bloom" : 0, #Bloom is messured in degrees
	"bloom_increase" : 0, #Amount of bloom increase per shot from center shot, increases on both sides
	"max_bloom" : 0, #Max amount of bloom
	"ammo_round" : 0, #Number of shots before reloading
	"current_ammo" : 0, #Current Ammo
	"time_to_reload" : 0, #Amount of time to reload
	"reload_timer" : 0, #Count down timer for reload time
	"weapon_cooldown":0, #Time between shots
	"cooldown_timer" : 0, #Used for counting down weapon cooldown
	"weapon_direction_change" : 0, #Directional change in RADIANS (Adjusted in weapon type)
	"pos_offset" : Vector2() #Offset of weapon from center
}

var weapon_database = {
	"None": {
	},
	"smg":{
		"projectile_type" : "single",
		"bloom" : 0, #Bloom is messured in degrees
		"bloom_increase" : 1.2, #Amount of bloom increase per shot from center shot, increases on both sides, in degrees
		"max_bloom" : 10, #Max amount of bloom
		"ammo_round" : 20, #Number of shots before reloading
		"current_ammo" : 20, #Current Ammo
		"time_to_reload" : 160, #Amount of time to reload
		"reload_timer" : 0, #Count down timer for reload time
		"weapon_cooldown":7, #Time between shots 
		"cooldown_timer" : 0, #Used for counting down weapon cooldown
		"weapon_direction_change" : PI/2, #Directional change in RADIANS (Adjusted in weapon type)
		"pos_offset" : Vector2(0,4) #Offset of weapon from center
	}
}

var gun_distance = 10 #Distance from player (radius)
var rotation_speed = 10 #Rotation speed of weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	if weapon_type == '':
		weapon_type='smg'
	weapon=weapon_database[weapon_type]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	calc_target_and_when_to_shoot()
	
	var pos = get_parent().global_position
	#Calculates angle to face towards target
	var angle =(target-pos).angle()
	var angle_delta = rotation_speed * delta
	rotation = lerp_angle(global_rotation,angle,0.7)
	
	#Creates a "ring" that the gun swivels around
	position=Vector2(cos(rotation)*gun_distance,sin(rotation)*gun_distance)
	position+=weapon.pos_offset
	#Flips gun sprite to match direction that it is aiming
	if target.x < get_parent().global_position.x:
		$Sprite.flip_v=true
	else:
		$Sprite.flip_v=false

func create_bullet(angle_adjust): #Creates instance of bullet
		var b = projectile.instance()
		#Sets projectile type
		b.type = weapon.projectile_type
		#Sets rotation and position
		#b.direction = self.global_rotation+PI/2
		b.direction = self.global_rotation + weapon.weapon_direction_change + angle_adjust
		b.global_position=self.global_position
		#Sets name of shooter to not deal damage to them
		#Owner name instead of self because self is weapon not shooter
		b.shooter_name=owner.name 
		#Double parent to get parent of shooter who is parent of weapon
		get_parent().get_parent().add_child(b) #Adds bullet to scene tree

func calc_target_and_when_to_shoot():
	if user == "player":
		#Get Targets (Mouse)
		target=get_global_mouse_position() 
		#Logic of when to shoot (when mouse pressed)
		if Input.is_action_pressed("ui_accept"):
			shoot=true
		else:
			shoot=false
	elif user == "Land_Enemy":
		if get_parent().player:
			#Get target (Player_Pos)
			target=get_parent().player.global_position
		#Logic of when to shoot (when player is visble and in range)
		if get_parent().player_visible == true:
			shoot=true
		else:
			shoot=false

func shoot():
	if weapon.reload_timer < 0: #If NOT reloading
		if weapon.current_ammo > 0: #Checks if has ammo
			if weapon.cooldown_timer < 1:
				if shoot:
					weapon.cooldown_timer=weapon.weapon_cooldown #Resetting cooldown timer
					weapon.bloom+=weapon.bloom_increase #Adding bloom per shot
					weapon.bloom=clamp(weapon.bloom,-weapon.max_bloom,weapon.max_bloom)
					#Create bullet with rand_range made with bloom
					create_bullet(rand_range(-deg2rad(weapon.bloom),deg2rad(weapon.bloom)))
					weapon.current_ammo-=1
			else: #If on weapon_cooldown
				weapon.cooldown_timer-=1
		else: #If out of ammo
			weapon.reload_timer=weapon.time_to_reload
			weapon.current_ammo=weapon.ammo_round
			weapon.bloom=0
	else: #If on reload timer
		weapon.reload_timer-=1
