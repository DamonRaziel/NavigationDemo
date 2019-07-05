extends KinematicBody

var move_speed = 0.25
var is_player = true

func _ready():
	pass # Replace with function body.

func _process(delta):
	is_player_id_method()

func _input(event):
	if Input.is_action_pressed("ui_right"):
		self.global_transform.origin.x += move_speed
	elif Input.is_action_pressed("ui_left"):
		self.global_transform.origin.x -= move_speed
	elif Input.is_action_pressed("ui_up"):
		self.global_transform.origin.z -= move_speed
	elif Input.is_action_pressed("ui_down"):
		self.global_transform.origin.z += move_speed

func is_player_id_method():
	is_player = true