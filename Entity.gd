extends KinematicBody2D

class_name base_entity

#Movement variables
const GRAVITY = 200 #900
const MAX_WALK_SPEED = 80

const ground_acceleration = 40
const air_acceleration = 5

const JUMP_FORCE = 117

const FRICTION = 0.15

var is_moving = false
var is_hit = false

var velocity = Vector2()

#Player Variables
var is_flipped = false

#Knockback variables
var percentage = 0
var weight = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func hit(body):
	if is_hit == false:
		var distance = 300
		percentage+=body.damage
		distance=300*(1+(percentage/100))
		velocity=Vector2(distance*cos(deg2rad(body.attack_angle)),-distance*sin(deg2rad(body.attack_angle)))

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	
	if is_flipped == false:
		$Sprite.flip_h=false
	elif is_flipped == true:
		$Sprite.flip_h=true
	
	if is_moving == false:
		# smoothen the stop
		velocity.x = lerp(velocity.x, 0, FRICTION)
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_Hitbox_area_entered(area):
	if "attack_frames" in area:
		hit(area)
		is_hit = true
		is_moving = true


func _on_Hitbox_area_exited(area):
	is_hit = false
	is_moving = false

func move_left():
	velocity.x =-MAX_WALK_SPEED
	is_moving = true
	is_flipped = true


func move_right():
	velocity.x=MAX_WALK_SPEED
	is_moving = true
	is_flipped = false
