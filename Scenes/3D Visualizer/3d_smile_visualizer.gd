extends Node3D

var atoms = []
@onready var structure = $Structure
var holding_left_click = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_elements()
	add_connections()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true:
			holding_left_click = true
		if event.button_index == 1 and event.pressed == false:
			holding_left_click = false
	if event is InputEventMouseMotion:
		if not holding_left_click:
			return
		var mouse_position = event.relative
		structure.rotate_x(.01 * mouse_position.y)
		structure.rotate_y(.01 * mouse_position.x)


func add_elements():
	var elements_file = FileAccess.open("elements.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" ", false)
		var symbol = split_data[0]
		var index = split_data[1]
		var x_position = float(split_data[2]) * 1
		var y_position = float(split_data[3]) * 1
		var z_position = float(split_data[4]) * 1
		var atom_node = CSGSphere3D.new()
		structure.add_child(atom_node)
		atom_node.global_position = Vector3(x_position, y_position, z_position)
		atoms.append(atom_node)

func add_connections():
	var elements_file = FileAccess.open("connections.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" - ", false)
		var first_index = int(split_data[0])
		var second_index = int(split_data[1])
		var first_element_position = atoms[first_index].global_position
		var second_element_position = atoms[second_index].global_position
		
		var new_connection = CSGCylinder3D.new()
		structure.add_child(new_connection)
		new_connection.radius = .1
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		new_connection.height = distance
		
		var normalized_direction = direction.normalized()
		var connection_up_vector = Vector3(0, 1, 0)
		if normalized_direction.cross(connection_up_vector).length() == 0:
			connection_up_vector = Vector3(0, 0, 1)
		var connection_quaternion = Quaternion(connection_up_vector, normalized_direction)
		new_connection.transform = Transform3D(connection_quaternion, first_element_position + normalized_direction * distance * .5)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")
