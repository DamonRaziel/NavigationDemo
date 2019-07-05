extends Spatial

var waypoints = []
var waypoints_number

func _ready():
	#add children as array points and count them (not sure if it counts grandchildren
	waypoints_number = get_child_count()
	waypoints = get_children()



