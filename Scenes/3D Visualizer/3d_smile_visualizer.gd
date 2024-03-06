extends Node3D

# Node references using `onready` to get the nodes from the scene
@onready var structure = $Structure
@onready var h_box_container = $"Control/SMILES Container/ScrollContainer/HBoxContainer"
@onready var neighbors_checkbox = $Control/Options/Neighbors
@onready var rings_checkbox = $Control/Options/Rings
@onready var back = $Control/Back
@onready var option_button = $Control/Options/HBoxContainer/OptionButton
@onready var fragment_text = $"Control/SMILES Container/Fragment_text"

# Preloading the scenes for 3D representation of atoms and bonds
const BASE_ATOM_3D = preload("res://Scenes/Atoms/base_atom_3d.tscn")
const SINGLE_BOND_3D = preload("res://Scenes/Bonds/single_bond_3d.tscn")
const DOUBLE_BOND_3D = preload("res://Scenes/Bonds/double_bond_3d.tscn")
const TRIPLE_BOND_3D = preload("res://Scenes/Bonds/triple_bond_3d.tscn")
const ARROMATIC_BOND_3D = preload("res://Scenes/Bonds/arromatic_bond_3d.tscn")

# Preloading the font
const COUR = preload("res://Fonts/cour.ttf")

# Variables to store the atoms, bonds, rings, and highlighted elements
var atoms = []
var bonds = []
var rings = []
var highlighted_atoms = []
var highlighted_bonds = []
var highlighted_connected_atoms = []
var highlighted_connected_bonds = []
var atom_buttons = []

# Variables to store the state of the application
var ctrl_pressed = false
var fragment = false
var holding_left_click = false

# Initializes elements, connections, rings, hides or shows fragment text, and sets initial colors.
func _ready():
	fragment_text.visible = false
	await add_elements()
	await add_connections()
	await add_rings()
	await generate_smiles_array()
	Globals.modulate_highlight.connect(_on_update_colors)
	Globals.node_clicked.connect(_on_node_pressed)
	Globals.modulate_highlight.emit()
	_on_enter_colors()
	if fragment:
		fragment_text.visible = true

# Sets the option button to the selected color
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

# Applies the selected color to the UI elements
func _on_update_colors():
	back.add_theme_color_override("font_color", Globals.selected_color)
	option_button.add_theme_color_override("font_color", Globals.selected_color)
	
	var stylebox = generate_theme_stylebox()
	for button in atom_buttons:
		if button is String:
			continue
		button.add_theme_stylebox_override("pressed", stylebox)
	

# Emits the camera position and handles multi-select input.
func _process(delta):
	Globals.camera_position.emit($Camera3D.global_position)
	if Input.is_action_just_pressed("multi-select"):
		ctrl_pressed = true
	if Input.is_action_just_released("multi-select"):
		ctrl_pressed = false

# Helper functions to determine if a string contains alphabetic characters and if a character is alphabetic.
func contains_alpha_char(characters: String) -> bool:
	for character in characters:
		if is_alpha(character):
			return true
	return false

# Helper function to determine if a character is alphabetic.
func is_alpha(character: String) -> bool:
	if character.length() == 0:
		return false
	var code = character[0].to_ascii_buffer()[0]
	return (code >= 'a'.to_ascii_buffer()[0] and code <= 'z'.to_ascii_buffer()[0]) or (code >= 'A'.to_ascii_buffer()[0] and code <= 'Z'.to_ascii_buffer()[0])

# Generates an array of SMILES representation buttons.
# The array is generated from a text file containing the SMILES representation of atoms.
# The array is then added to the HBoxContainer.
# The array is then connected to the update_buttons function.
# Atom is checked for alpha characters and if it contains alpha characters, the atom is added to the array.
func generate_smiles_array():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "smiles.txt",FileAccess.READ)
	var elements_text = elements_file.get_as_text().strip_edges()
	var elements = elements_text.split(" ")
	var stylebox = generate_theme_stylebox()
	var element_idx = 0
	for element in elements:
		var new_button = Button.new()
		new_button.add_theme_font_size_override("font_size", 50)
		new_button.add_theme_stylebox_override("pressed", stylebox)
		new_button.add_theme_font_override("font", COUR)
		new_button.toggle_mode = true
		new_button.text = str(element)
		h_box_container.add_child(new_button)
		if contains_alpha_char(element):
			if atoms[element_idx] is String:
				new_button.disabled = true
				atom_buttons.append("")
			else:
				atom_buttons.append(new_button)
				new_button.pressed.connect(update_buttons.bind(new_button))
			element_idx += 1
		else:
			new_button.disabled = true

# Generates a stylebox for the selected color.
func generate_theme_stylebox():
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = Color(Globals.selected_color, .5)
	return new_stylebox

# Updates the buttons and highlights the atoms and bonds.
func _on_node_pressed(atom_node):
	var atom_idx = atoms.find(atom_node)
	if atom_idx >= atom_buttons.size():
		return
	var relative_button = atom_buttons[atom_idx]
	if relative_button:
		relative_button.button_pressed = true
		update_buttons(relative_button)

# Updates the buttons and highlights the atoms and bonds.
func update_buttons(button_node):
	if ctrl_pressed:
		update_highlights()
		return
	for button in atom_buttons:
		if button is String:
			continue
		if button == button_node:
			continue
		button.button_pressed = false
	update_highlights()

# Updates the highlights of the atoms and bonds.
func update_highlights():
	for atom in highlighted_atoms:
		atom.turn_off_highlight.call_deferred()
	for bond in highlighted_bonds:
		bond.turn_off_highlight.call_deferred()
	highlighted_atoms.clear()
	highlighted_bonds.clear()
	for idx in atom_buttons.size():
		if atom_buttons[idx] is String:
			continue
		if atom_buttons[idx].button_pressed == true:
			var current_atom = atoms[idx]
			current_atom.turn_on_highlight.call_deferred()
			highlighted_atoms.append(current_atom)
	for bond in bonds:
		if bond.check_if_connected_atoms(highlighted_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_bonds.append(bond)
	clear_connected_highlights()
	if neighbors_checkbox.button_pressed:
		highlight_connected()
	if rings_checkbox.button_pressed:
		highlight_rings()

# Highlights the connected atoms and bonds.
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
	for atom in highlighted_connected_atoms:
		var atom_idx = atoms.find(atom)
		atom_buttons[atom_idx].button_pressed = true

# Highlights the rings.
func highlight_rings():
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()
	for atom in highlighted_atoms:
		var atom_idx = atoms.find(atom)
		for ring in rings:
			if str(atom_idx) in ring:
				# Highlight all atoms in ring
				for atom_index in ring:
					atoms[int(atom_index)].turn_on_highlight.call_deferred()
					highlighted_connected_atoms.append(atoms[int(atom_index)])
	for bond in bonds:
		if bond.check_if_connected_atoms(highlighted_connected_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_connected_bonds.append(bond)
	for atom in highlighted_connected_atoms:
		var atom_idx = atoms.find(atom)
		atom_buttons[atom_idx].button_pressed = true

# Clears the connected highlights.
func clear_connected_highlights():
	for atom in highlighted_connected_atoms:
		if atom in highlighted_atoms:
			continue
		atom.turn_off_highlight()
		var atom_idx = atoms.find(atom)
		atom_buttons[atom_idx].button_pressed = false
	for bond in highlighted_connected_bonds:
		if bond in highlighted_bonds:
			continue
		bond.turn_off_highlight()
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()

# Adds the elements to the scene.
# The elements are read from a text file and added to the scene.
# The elements are added to the atoms array.
# If the x, y, and z positions are -1, the element is a fragment and thus the atoms array is appended with an empty string.
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
		var charge = int(split_data[5])
		if x_position == -1 and y_position == -1 and z_position == -1:
			atoms.append("")
			fragment = true
			continue
		var atom_node = BASE_ATOM_3D.instantiate()
		structure.add_child(atom_node)
		atom_node.global_position = Vector3(x_position, y_position, z_position)
		atom_node.update_atom(symbol, charge)
		atoms.append(atom_node)

# Adds the connections to the scene.
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

# Adds the rings to the scene.
func add_rings():
	var base_path = ProjectSettings.globalize_path("res://")
	var rings_file = FileAccess.open(base_path + "rings.txt",FileAccess.READ)
	var rings_data = rings_file.get_as_text().split("\n")
	for ring in rings_data:
		var elements = ring.strip_edges().split(" ")
		rings.append(elements)

# Returns the connection based on the bond type.
func get_connection(bond_type):
	if bond_type == "1.0":
		return SINGLE_BOND_3D.instantiate()
	if bond_type == "2.0":
		return DOUBLE_BOND_3D.instantiate()
	if bond_type == "3.0":
		return TRIPLE_BOND_3D.instantiate()
	if bond_type == "1.5":
		return ARROMATIC_BOND_3D.instantiate()
	return SINGLE_BOND_3D.instantiate()

# Returns the connection based on the bond type.
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")

# Sets the selected color based on the option button index.
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

# Clears the connected highlights and highlights the neighbors or rings.
func _on_neighbors_pressed():
	clear_connected_highlights()
	if neighbors_checkbox.button_pressed:
		rings_checkbox.button_pressed = false
		highlight_connected()

# Clears the connected highlights and highlights the neighbors or rings.
func _on_rings_pressed():
	clear_connected_highlights()
	if rings_checkbox.button_pressed:
		neighbors_checkbox.button_pressed = false
		highlight_rings()

# Rotates the structure based on the mouse position.
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 2 and event.pressed == true:
			holding_left_click = true
		if event.button_index == 2 and event.pressed == false:
			holding_left_click = false
	if event is InputEventMouseMotion:
		if not holding_left_click:
			return
		var mouse_position = event.relative
		structure.rotate_x(.01 * mouse_position.y)
		structure.rotate_y(.01 * mouse_position.x)
