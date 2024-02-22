extends Node3D

@onready var structure = $Structure
@onready var h_box_container = $"Control/SMILES Container/ScrollContainer/HBoxContainer"
@onready var check_box = $Control/Options/CheckBox
@onready var back = $Control/Back
@onready var option_button = $Control/Options/HBoxContainer/OptionButton
const BASE_ATOM_3D = preload("res://Scenes/Atoms/base_atom_3d.tscn")
const SINGLE_BOND_3D = preload("res://Scenes/Bonds/single_bond_3d.tscn")



var atoms = []
var bonds = []

var highlighted_atoms = []
var highlighted_bonds = []
var highlighted_connected_atoms = []
var highlighted_connected_bonds = []
var atom_buttons = []

var ctrl_pressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	await add_elements()
	await add_connections()
	await generate_smiles_array()
	Globals.modulate_highlight.connect(_on_update_colors)
	Globals.modulate_highlight.emit()
	_on_enter_colors()

func _on_enter_colors():
	var selected_button = null
	if Globals.selected_color == Globals.NEON_RED:
		option_button.selected = 0
	elif  Globals.selected_color == Globals.NEON_PURPLE:
		option_button.selected = 1
	elif  Globals.selected_color == Globals.NEON_GREEN:
		option_button.selected = 2
	elif  Globals.selected_color == Globals.NEON_YELLOW:
		option_button.selected = 3
	else:
		option_button.selected = 2

func _on_update_colors():
	back.add_theme_color_override("font_color", Globals.selected_color)
	option_button.add_theme_color_override("font_color", Globals.selected_color)
	
	var stylebox = generate_theme_stylebox()
	for button in atom_buttons:
		button.add_theme_stylebox_override("pressed", stylebox)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Globals.camera_position.emit($Camera3D.global_position)
	if Input.is_action_just_pressed("multi-select"):
		print("Ctrl Pressed Now")
		ctrl_pressed = true
	if Input.is_action_just_released("multi-select"):
		ctrl_pressed = false

func contains_alpha_char(characters: String) -> bool:
	for character in characters:
		if is_alpha(character):
			return true
	return false

func is_alpha(character: String) -> bool:
	if character.length() == 0:
		return false
	var code = character[0].to_ascii_buffer()[0]
	return (code >= 'a'.to_ascii_buffer()[0] and code <= 'z'.to_ascii_buffer()[0]) or (code >= 'A'.to_ascii_buffer()[0] and code <= 'Z'.to_ascii_buffer()[0])

func generate_smiles_array():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "smiles.txt",FileAccess.READ)
	var elements_text = elements_file.get_as_text().strip_edges()
	var elements = elements_text.split(" ")
	var stylebox = generate_theme_stylebox()
	for element in elements:
		var new_button = Button.new()
		new_button.add_theme_font_size_override("font_size", 50)
		new_button.add_theme_stylebox_override("pressed", stylebox)
		new_button.toggle_mode = true
		new_button.text = str(element)
		h_box_container.add_child(new_button)
		if contains_alpha_char(element):
			atom_buttons.append(new_button)
			new_button.pressed.connect(update_buttons.bind(new_button))
		else:
			new_button.disabled = true

func generate_theme_stylebox():
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = Globals.selected_color
	return new_stylebox

func update_buttons(button_node):
	if ctrl_pressed:
		update_highlights()
		return
	for button in atom_buttons:
		if button == button_node:
			continue
		button.button_pressed = false
	update_highlights()

func update_highlights():
	for atom in highlighted_atoms:
		atom.turn_off_highlight.call_deferred()
	for bond in highlighted_bonds:
		bond.turn_off_highlight.call_deferred()
	highlighted_atoms.clear()
	highlighted_bonds.clear()
	for idx in atom_buttons.size():
		if atom_buttons[idx].button_pressed == true:
			var current_atom = atoms[idx]
			current_atom.turn_on_highlight.call_deferred()
			highlighted_atoms.append(current_atom)
	for bond in bonds:
		if bond.check_if_connected_atoms(highlighted_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_bonds.append(bond)
	clear_connected_highlights()
	if check_box.button_pressed:
		highlight_connected()

func highlight_connected():
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()
	for bond in bonds:
		if bond.check_if_contains_atoms(highlighted_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_connected_bonds.append(bond)
			for atom in bond.connected_atoms:
				atom.turn_on_highlight.call_deferred()
				highlighted_connected_atoms.append(atom)

func clear_connected_highlights():
	for atom in highlighted_connected_atoms:
		if atom in highlighted_atoms:
			continue
		atom.turn_off_highlight()
	for bond in highlighted_connected_bonds:
		if bond in highlighted_bonds:
			continue
		bond.turn_off_highlight()
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()

func add_elements():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "elements.txt",FileAccess.READ)
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
		var atom_node = BASE_ATOM_3D.instantiate()
		structure.add_child(atom_node)
		if x_position == 0 and y_position == 0 and z_position == 0:
			x_position = 5
			y_position = 5
			z_position = 5
		atom_node.global_position = Vector3(x_position, y_position, z_position)
		atom_node.update_atom(symbol)
		atoms.append(atom_node)

func add_connections():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "connections.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" - ", false)
		var first_index = int(split_data[0])
		var second_index = int(split_data[1])
		var bond_type = split_data[2]
		var first_element_position = atoms[first_index].global_position
		var second_element_position = atoms[second_index].global_position
		
		var new_connection = get_connection(bond_type)
		structure.add_child(new_connection)
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		
		var height = distance
		
		var normalized_direction = direction.normalized()
		var connection_up_vector = Vector3(0, 1, 0)
		if normalized_direction.cross(connection_up_vector).length() == 0:
			connection_up_vector = Vector3(0, 0, 1)
		var connection_quaternion = Quaternion(connection_up_vector, normalized_direction)
		new_connection.transform = Transform3D(connection_quaternion, first_element_position + normalized_direction * distance * .5)
		#if atoms[first_index].get_node("Label") and atoms[first_index].get_node("Label").text != "":
			#new_connection.global_position = first_element_position + direction * .2
			#height -= distance * .2
		#else:
			#new_connection.global_position = first_element_position # + direction * .2
		#if atoms[second_index].get_node("Label") and atoms[second_index].get_node("Label").text != "":
			#height -= distance * .2
		new_connection.scale.y = distance
		
		var new_bond = Bond_3D.new(new_connection, atoms[first_index], atoms[second_index])
		bonds.append(new_bond)


func get_connection(bond_type):
	if bond_type == "1.0":
		return SINGLE_BOND_3D.instantiate()
	#if bond_type == "2.0":
		#return DOUBLE_BOND.instantiate()
	#if bond_type == "3.0":
		#return TRIPLE_BOND.instantiate()
	#if bond_type == "1.5":
		#return ARROMATIC_BOND.instantiate()
	return SINGLE_BOND_3D.instantiate()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")

func _on_option_button_item_selected(index):
	if index == 0:
		Globals.selected_color = Globals.NEON_RED
	if index == 1:
		Globals.selected_color = Globals.NEON_PURPLE
		
	if index == 2:
		Globals.selected_color = Globals.NEON_GREEN
		
	if index == 3:
		Globals.selected_color = Globals.NEON_YELLOW
	Globals.modulate_highlight.emit()


func _on_check_box_pressed():
	clear_connected_highlights()
	if check_box.button_pressed:
		highlight_connected()


var holding_left_click = false
func _input(event):
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
