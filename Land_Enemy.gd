extends KinematicBody2D

#Preload instances of scenes
var projectile = preload("res://Projectile.tscn") #Preload Projectile Scene

#Preload instance of Health Bar
var health_bar = preload("res://Health_Bar.tscn") #Preload Projectile Scene

#Player Based Variables
var player_in_range = false
var player = null
var player_close = false
var player_visible = false

#Enemy type
var enemy_type = ''

#Defines enemy variables
var enemy = {
		#Movement Based Variables
		"max_velocity" : Vector2(),
		"velocity" : Vector2(), #Adjusted in inputs
		"acc" : 1, #Acceleration
		"initial_velocity" : Vector2(),
		"initial_direction" : 0,
		#Weapon variables
		"weapon_type":"None",
		"user":"",
		#Health based variables
		"health" : 0, #Health of enemy
		"max_health" : 0, #Full health of enemy
		#Area Variables
		"in_range_radius" : 0, #Radius of in_range area2d
		"min_distance_radius" : 0, #Radius of min_distance_radius area2d
		#Sprite Variables
		"sprite_region_rect" : Rect2(0,0,0,0),
		#Collision Variables
		"collision_pos" : Vector2(),
		"collision_shape_extents" : Vector2()
}

#Database of enemy statistics
var enemy_database = {
	"crawler" : {
		#Movement Based Variables
		"max_velocity" : Vector2(20,20),
		"velocity" : Vector2(), #Adjusted in inputs
		"acc" : 1, #Acceleration
		"initial_velocity" : Vector2(10,5),
		"initial_direction" : -3*PI/2,
		#Weapon variables
		"weapon_type":"smg",
		"user":"Land_Enemy",
		#Health based variables
		"health" : 10, #Health of enemy
		"max_health" : 10, #Full health of enemy
		#Area Variables
		"in_range_radius" : 99, #Radius of in_range area2d
		"min_distance_radius" : 45, #Radius of min_distance_radius area2d
		#Sprite Variables
		"sprite_region_rect" : Rect2(0,0,18,14),
		#Collision Variables
		"collision_pos" : Vector2(),
		"collision_shape_extents" : Vector2(9,8)
	},
	"gunner" : {
		#Movement Based Variables
		"max_velocity" : Vector2(0,-10),
		"velocity" : Vector2(), #Adjusted in inputs
		"acc" : 1,
		"initial_velocity" : Vector2(0,-10),
		"initial_direction" : -3*PI/2,
		#Area Variables
		"in_range_radius" : 140, #Radius of in_range area2d
		"min_distance_radius" : 130, #Radius of min_distance_radius area2d
		#Sprite Variables
		"sprite_region_rect" : Rect2(36,0,13,15),
		#Collision Variables
		"collision_pos" : Vector2(),
		"collision_shape_extents" : Vector2(7,8)
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if enemy_type == '':
		enemy_type='crawler'
	enemy=enemy_database[enemy_type]
	if enemy.weapon_type=="None":
		$Weapon_Land.hide()
	$Weapon_Land.user=enemy.user
	health_bar() #Creates health bar
	update_collision_and_sprite()

func debug_when_adjust_enemy_vars():
	if enemy_database[enemy_type].has_all(enemy.keys()): #Checks if both enemy type and enemy dictionary have the same keys
		print('Has all Variables needed')
	else: #Debugging if dictionary entry does not have all keys needed
		for i in range(len(enemy.keys())):
			if not enemy.keys()[0+i] in enemy_database[enemy_type]:
				print("Enemy doesnt have key:",enemy.keys()[0+i])


func update_collision_and_sprite(): #Called when creating enemy
	$In_Range/CollisionShape2D.shape.radius=enemy.in_range_radius
	$Min_Distance/CollisionShape2D.shape.radius=enemy.min_distance_radius
	$Sprite.region_rect=enemy.sprite_region_rect
	$CollisionShape2D.position=enemy.collision_pos
	$CollisionShape2D.shape.extents=enemy.collision_shape_extents

func get_movement():
	if player_in_range == true:
		$RayCast2D.cast_to=player.global_position-position
		if not $RayCast2D.is_colliding():
			player_visible = true
			var player_pos=player.global_position
			enemy.velocity.x=lerp(enemy.velocity.x,0,0.2)
			if not player_close:
				if player_pos.x < global_position.x:
					enemy.velocity.x=lerp(enemy.velocity.x,-enemy.max_velocity.x,enemy.acc)
				else:
					enemy.velocity.x=lerp(enemy.velocity.x,enemy.max_velocity.x,enemy.acc)
				if player_pos.y <global_position.y:
					enemy.velocity.y=lerp(enemy.velocity.y,-enemy.max_velocity.y,enemy.acc)
				else:
					enemy.velocity.y=lerp(enemy.velocity.y,enemy.max_velocity.y,enemy.acc)
			elif player_close:
				enemy.velocity.y=lerp(enemy.velocity.y,0,enemy.acc)
		elif $RayCast2D.is_colliding():
			player_visible = false
			enemy.velocity=enemy.initial_velocity
	elif player_in_range == false:
		enemy.velocity=enemy.initial_velocity
		player_visible=false

func shoot():
	if enemy.weapon_type != "None":
		$Weapon_Land.shoot()

func hit(damage): #Called when hit by bullets
	enemy.health-=damage

func damage_calc():
	if enemy.health < 1:
		queue_free()

func health_bar():
	var bar = health_bar.instance()
	add_child(bar)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_movement()
	damage_calc()
	shoot()
	enemy.velocity = move_and_slide(enemy.velocity)

#Check if player is in range
func _on_In_Range_body_entered(body):
	if body.name == "Player_Land":
		player_in_range = true
		player=body
func _on_In_Range_body_exited(body):
	if body.name == "Player_Land":
		player_in_range = false
		player=null

#Check if player is to close
func _on_Min_Distance_body_entered(body):
	player_close = true
func _on_Min_Distance_body_exited(body):
	player_close = false
