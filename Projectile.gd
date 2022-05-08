extends Area2D

var shooter_name = ""
var type = ""

var  direction = null #direction of bullet (set by ship)

var projectile = {
		velocity=0,#speed of bullet
		damage = 0,#how long the bullet will last
		duration = 0,
		sprite_region_rect=Rect2(0,0,0,0),#Set when type is called
		collision_extents=Vector2(0,0)
	}

var projectile_database = {
	"single":{
		velocity=120,
		damage = 1,
		duration = 100,
		sprite_region_rect=Rect2(0,0,1,1),
		collision_extents=Vector2(1,1)
	},
	"heavy":{
		velocity = 250,
		damage = 5,
		duration = 80,
		sprite_region_rect=Rect2(0,3,9,1),
		collision_extents=Vector2(4,1)
	}
}

func _ready():
	hide() #Hides bullet until all variables are passed on by ship to prevent visual error
	if type =="":
		type="single"
	#Sets projectile data to type referenced in database
	projectile=projectile_database[type]
	$Sprite.region_rect=projectile.sprite_region_rect
	$CollisionShape2D.shape.extents=projectile.collision_extents

func _physics_process(delta):
	if direction != null: #Checks if direction is not null to prevent stutter of projectiles at beginning
		show()
	#Vector 2 has x = -1 to shoot forward relative to shooter
	#PI/2 Added so bullets appeaer correctly rotated 
	global_position += Vector2(-1,0).rotated(direction+PI/2) * projectile.velocity * delta
	#Sets rotation equal to direction to point bullets forward
	rotation = direction+PI/2
	if projectile.duration < 0: #If bullet duration ends, delete bullet
		queue_free()
	else: #counts down duration
		projectile.duration-=1

func debug_when_adjust_projectile_vars():
	if projectile_database[type].has_all(projectile.keys()): #Checks if both enemy type and enemy dictionary have the same keys
		print('Has all Variables needed')
	else: #Debugging if dictionary entry does not have all keys needed
		for i in range(len(projectile.keys())):
			if not projectile.keys()[0+i] in projectile_database[type]:
				print("Enemy doesnt have key:",projectile.keys()[0+i])


func _on_Projectile_body_entered(body):
	if body.name != shooter_name:
		if body.has_method("hit"):
			body.hit(projectile.damage)
		queue_free()


func _on_Projectile_area_entered(area): #Collisions with area 2ds such as shields, area_is_active has to be true to collide
	if area.get_parent().name != shooter_name:
		if "area_is_active" in area:
			if area.area_is_active == true:
				if area.has_method("hit"):
					area.hit(projectile.damage)
				queue_free()
