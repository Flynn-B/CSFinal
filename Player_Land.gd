extends KinematicBody2D


#Movement variables
export var speed = 90
export var friction = 0.3
export var acceleration = 0.5

var direction = Vector2()

#Dash variables
var is_dashing = false
const dash_time = 10 #Frame times for dash_timer
var dash_timer = 0 #Count down for timer
const dash_cooldown_time = 25 #Frames  of cooldown for dash
var dash_cooldown_timer = 0 #Count down for cooldown timer
const dash_speed = 200 #Speed of dash

var velocity = Vector2()

func get_input():
	direction = Vector2.ZERO
	if Input.is_action_pressed('right'):
		direction.x += 1
	if Input.is_action_pressed('left'):
		direction.x -= 1
	if Input.is_action_pressed('down'):
		direction.y += 1
	if Input.is_action_pressed('up'):
		direction.y -= 1
	#Dashing
	if Input.is_action_just_pressed("dash") and not dash_cooldown_timer > 0:
		var target = get_global_mouse_position()
		velocity=target-position
		velocity = velocity.normalized() * dash_speed
		is_dashing = true
		dash_timer = dash_time
		dash_cooldown_timer = dash_cooldown_time
	if dash_timer > 0:
		dash_timer-=1
	else:
		is_dashing = false
		if dash_cooldown_timer > 0:
			dash_cooldown_timer-=1

func weapon():
	#Flips Player_Sprite to face same way gun is
	$Sprite.flip_h=$Weapon_Land/Sprite.flip_v
	$Weapon_Land.shoot()

func _physics_process(delta):
	get_input()
	weapon()
	if not is_dashing:
		if direction.length() > 0:
			velocity = lerp(velocity, direction.normalized() * speed, acceleration)
		else:
			velocity = lerp(velocity, Vector2.ZERO, friction)
	velocity = move_and_slide(velocity)
