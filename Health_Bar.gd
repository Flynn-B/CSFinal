extends Node2D

var length = 12
var bar_distance = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	$Bar_Boundries.rect_size = Vector2(3,length+2)
	$Missing_Health.rect_size = Vector2(1,length)
	$Health.rect_size = Vector2(1,length)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Checking if parent has health and max_health to avoid crashes
	#if "enemy".has('health') in get_parent() and enemy.has('max_health') in get_parent():
	if "enemy" in get_parent():
		var health_percentage = float(get_parent().enemy.health)/float(get_parent().enemy.max_health)
		$Health.rect_size = Vector2(1,length*health_percentage)
		#Resetting global_rotation to make health bar be upright
		global_rotation=PI/2
		#Setting health_bar position above enemy
		global_position=get_parent().global_position+Vector2(length/2,-bar_distance)
