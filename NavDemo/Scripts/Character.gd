extends KinematicBody

var speed = 1.5

var character_origin
var character

var target = null

var navmesh
var path = []

var begin = Vector3()
var end = Vector3()

var waypoint_numbers_to_choose_from
var waypoint_number_chosen

var character_state = 0
#0 = idle, 1 = wander randomly, 2 = chase player, 3 = attack player, 4 = retreat

var dtimer
var decision

var character_waypoints

var is_active = true

onready var s_timer = get_node("ScanTimer")
onready var s_timer2 = get_node("ScanTimer2")

#onready var nav_main = get_parent()
#
#onready var character_waypoints = nav_main.get_node("WaypointHolder").waypoints
#onready var waypoint_numbers_to_choose_from = nav_main.get_node("WaypointHolder").waypoints_number

func _ready():
	character = get_node(".")
	navmesh = get_parent().get_parent()
	character_waypoints = navmesh.get_node("WaypointHolder").waypoints
	waypoint_numbers_to_choose_from = navmesh.get_node("WaypointHolder").waypoints_number
	print(character_waypoints)
	print (waypoint_numbers_to_choose_from)
	dtimer = get_node("DecisionTimer")
#	death_timer = get_node("DeathTimer")
	if is_active == true:
		idle_for_a_moment()

func _process(delta):
	#deals with movement when using navmesh
	#--Wandering Randomly--#
	if character_state == 1:
		if (path.size() > 1):
			var to_walk = delta*speed
			var to_watch = Vector3(0, 1, 0)
			while(to_walk > 0 and path.size() >= 2):
				var pfrom = path[path.size() - 1]
				var pto = path[path.size() - 2]
				to_watch = (pto - pfrom).normalized()
				var d = pfrom.distance_to(pto)
				if (d <= to_walk):
					path.remove(path.size() - 1)
					to_walk -= d
				else:
					path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
					to_walk = 0
				var atpos = path[path.size() - 1]
				var atdir = to_watch
				atdir.y = 0
				var t = Transform()
				t.origin = atpos
				t=t.looking_at(atpos + atdir, Vector3(0, 1, 0))
				set_transform(t)
				if (path.size() < 2):
					path = []
					idle_for_a_moment()
		else:
			set_process(false)
	#--Chasing Target--#
	elif character_state == 2:
		if (path.size() > 1):
			var to_walk = delta*speed
			var to_watch = Vector3(0, 1, 0)
			while(to_walk > 0 and path.size() >= 2):
				var pfrom = path[path.size() - 1]
				var pto = path[path.size() - 2]
				to_watch = (pto - pfrom).normalized()
				var d = pfrom.distance_to(pto)
				if (d <= to_walk):
					path.remove(path.size() - 1)
					to_walk -= d
				else:
					path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk/d)
					to_walk = 0
				
				var atpos = path[path.size() - 1]
				var atdir = to_watch
				atdir.y = 0
				
				var t = Transform()
				t.origin = atpos
				t=t.looking_at(atpos + atdir, Vector3(0, 1, 0))
				self.set_transform(t)
				if (path.size() < 2):
					path = []
					start_rescan()
		else:
			set_process(false)

func _physics_process(delta):
	pass

func _on_Detect_Area_body_entered(body):
	if body.has_method("is_player_id_method"):
		target = body
		print (body)
		print ("new target: ", target)
		character_state = 2
		dtimer.stop()
		calculate_path()
#	else:
#		pass
#		dtimer.stop()

func _on_Detect_Area_body_exited(body):
	if body.has_method("is_player_id_method"):
		target = null
		print ("new target: ", target)
		idle_for_a_moment()
#	else:
#		pass

func _on_DecisionTimer_timeout():
	if is_active == true:
		randomize()
		decision = randi()%2
		if decision == 0:
			idle_for_a_moment()
		elif decision == 1:
			pick_waypoint()
	else:
		dtimer.start()
		character_state = 0
		set_process(false)
		set_physics_process(false)

func idle_for_a_moment():
	dtimer.start()
	character_state = 0
	set_physics_process(false)
	set_process(false)

func pick_waypoint():
	randomize()
	waypoint_number_chosen = randi()%waypoint_numbers_to_choose_from
	target = character_waypoints[waypoint_number_chosen]
	character_state = 1
	print (target)
	calculate_path()

func calculate_path():
	begin = navmesh.get_closest_point(self.get_translation())
	end = navmesh.get_closest_point(target.get_translation())
	var p = navmesh.get_simple_path(begin, end, true) 
	path = Array(p)
	path.invert()
	set_process(true)
	set_physics_process(false)

func start_rescan():
	set_process(false)
	s_timer.start()

func rescan_for_target():
	var scan_area = $Detect_Area
	var scan_bodies = scan_area.get_overlapping_bodies()
	for scan_body in scan_bodies:
		if scan_body == self:
			continue
		if scan_body.has_method("is_player_id_method"): 
			calculate_path()

func _on_ScanTimer_timeout():
	rescan_for_target()

func _on_ScanTimer2_timeout():
	rescan_for_target()
	s_timer2.start()
