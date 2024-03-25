extends Node2D

# Constants for preloading scenes for different types of chemical bonds and a base atom scene.
const DOUBLE_BOND = preload("res://Scenes/Bonds/double_bond.tscn")
const SINGLE_BOND = preload("res://Scenes/Bonds/single_bond.tscn")
const TRIPLE_BOND = preload("res://Scenes/Bonds/triple_bond.tscn")
const ARROMATIC_BOND = preload("res://Scenes/Bonds/arromatic_bond.tscn")
const BASE_ATOM = preload("res://Scenes/Atoms/base_atom.tscn")

# Node references using 'onready' to ensure they are initialized when the script is ready.
@onready var structure = $Structure
@onready var h_box_container = $"Control/SMILES Container/ScrollContainer/HBoxContainer"
@onready var neighbors_checkbox = $Control/Options/Neighbors
@onready var rings_checkbox = $Control/Options/Rings

# Gets the viewport size for layout calculations.
@onready var viewport = get_viewport_rect().size

# UI elements for user interaction.
@onready var back = $Control/Back
@onready var option_button = $Control/Options/HBoxContainer/OptionButton
const COUR = preload("res://Fonts/cour.ttf")
const ELEMENT_BUTTON = preload("res://Utils/Element Button/element_button.tscn")

# Variables to store atoms, bonds, rings, and UI elements related to atoms.
var atoms = []
var bonds = []
var rings = []

# Variables for highlighting atoms and bonds based on user selection.
var highlighted_atoms = []
var highlighted_bonds = []
var highlighted_connected_atoms = []
var highlighted_connected_bonds = []
var atom_buttons = []

# A boolean to check if the control key is pressed, used for multi-selection.
var ctrl_pressed = false

# Initializes elements, connections, and rings on node entry, and connects signals for UI updates.
func _ready():
	await add_elements()
	await add_connections()
	await add_rings()
	await generate_smiles_array()
	Globals.modulate_highlight.connect(_on_update_colors)
	Globals.node_clicked.connect(_on_node_pressed)
	Globals.modulate_highlight.emit()
	_on_enter_colors()

# Updates the UI based on the globally selected color.
func _on_enter_colors():
	# Selects the appropriate option button based on the globally selected color.
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

# Updates colors of back and option_button to reflect the globally selected color.
func _on_update_colors():
	back.add_theme_color_override("font_color", Globals.selected_color)
	option_button.add_theme_color_override("font_color", Globals.selected_color)
	
	# Applies a new style to atom buttons based on the selected color.
	var stylebox = generate_theme_stylebox()
	for button in atom_buttons:
		button.add_theme_stylebox_override("pressed", stylebox)

# Handles the multi-select functionality based on user input.
func _process(_delta):
	if Input.is_action_just_pressed("multi-select"):
		ctrl_pressed = true
	if Input.is_action_just_released("multi-select"):
		ctrl_pressed = false

# Checks if a string contains alphabetic characters.
func contains_alpha_char(characters: String) -> bool:
	for character in characters:
		if is_alpha(character):
			return true
	return false

# Determines if a character is an alphabetic letter.
func is_alpha(character: String) -> bool:
	if character.length() == 0:
		return false
	var code = character[0].to_ascii_buffer()[0]
	return (code >= 'a'.to_ascii_buffer()[0] and code <= 'z'.to_ascii_buffer()[0]) or (code >= 'A'.to_ascii_buffer()[0] and code <= 'Z'.to_ascii_buffer()[0])

# Generates buttons for elements from a SMILES array, enabling dynamic UI for chemical structure manipulation.
func generate_smiles_array():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "smiles.txt",FileAccess.READ)
	var elements_text = elements_file.get_as_text().strip_edges()
	var elements = elements_text.split(" ")
	
	var element_index = 0
	# Creates buttons for each element and adds them to the UI, disabling non-alphabetic ones.
	for element in elements:
		var new_button = ELEMENT_BUTTON.instantiate()
		new_button.element_name = str(element)
		if contains_alpha_char(element) or element == "*":
			atom_buttons.append(new_button)
			new_button.pressed.connect(update_buttons.bind(new_button))
			new_button.element_index = element_index
			element_index += 1
		else:
			new_button.disabled = true
		h_box_container.add_child(new_button)

# Generates a stylebox for theme customization based on the selected color.
func generate_theme_stylebox():
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = Color(Globals.selected_color, .5)
	return new_stylebox

# Handles node press events, updating the UI accordingly.
func _on_node_pressed(atom_node):
	var atom_idx = atoms.find(atom_node)
	if atom_idx >= atom_buttons.size():
		return
	var relative_button = atom_buttons[atom_idx]
	if relative_button:
		relative_button.button_pressed = true
		update_buttons(relative_button)

# Updates button states and highlights based on the control key state and button presses.
func update_buttons(button_node):
	if ctrl_pressed:
		update_highlights()
		return
	for button in atom_buttons:
		if button == button_node:
			continue
		button.button_pressed = false
	update_highlights()

# Updates which atoms and bonds are highlighted based on user selection.
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
		var adjacent_hydrogen = bond.check_if_hydrogen_connected(highlighted_atoms)
		if adjacent_hydrogen:
			bond.turn_on_highlight.call_deferred()
			highlighted_bonds.append(bond)
			adjacent_hydrogen.turn_on_highlight.call_deferred()
			highlighted_atoms.append(adjacent_hydrogen)
	clear_connected_highlights()
	if neighbors_checkbox.button_pressed:
		highlight_connected()
	if rings_checkbox.button_pressed:
		highlight_rings()

# Highlights connected atoms and bonds.
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
		if atom_idx < atom_buttons.size():
			atom_buttons[atom_idx].button_pressed = true

# Highlights all atoms and bonds in rings that contain any of the highlighted atoms.
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
		if atom_idx < atom_buttons.size():
			atom_buttons[atom_idx].button_pressed = true

# Clears highlights from connected atoms and bonds that are not currently selected.
func clear_connected_highlights():
	for atom in highlighted_connected_atoms:
		if atom in highlighted_atoms:
			continue
		atom.turn_off_highlight()
		var atom_idx = atoms.find(atom)
		if atom_idx < atom_buttons.size():
			atom_buttons[atom_idx].button_pressed = false
	for bond in highlighted_connected_bonds:
		if bond in highlighted_bonds:
			continue
		bond.turn_off_highlight()
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()

func turn_on_index():
	for atom_button in atom_buttons:
		atom_button.turn_on_index()
	for atom in atoms:
		atom.turn_on_index()

func turn_off_index():
	for atom_button in atom_buttons:
		atom_button.turn_off_index()
	for atom in atoms:
		atom.turn_off_index()

# Loads and adds elements to the structure based on a configuration file.
func add_elements():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "two_d_elements.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" ", false)
		var symbol = split_data[0]
		var index = split_data[1]
		var x_position = float(split_data[2]) - viewport.x * .5
		var y_position = float(split_data[3]) - viewport.y * .5
		var charge = int(split_data[4])
		var atom_node = BASE_ATOM.instantiate()
		structure.add_child(atom_node)
		atom_node.global_position = Vector2(x_position, y_position)
		atom_node.update_atom(symbol, charge, index)
		atoms.append(atom_node)

# Parses and adds connections between atoms to visualize chemical bonds.
func add_connections():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "two_d_connections.txt",FileAccess.READ)
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
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		
		var height = distance
		var new_connection = get_connection(bond_type)
		structure.add_child(new_connection)
		if atoms[first_index].get_node("Atom Symbol") and atoms[first_index].get_node("Atom Symbol").text != "":
			new_connection.global_position = first_element_position + direction * .2
			height -= distance * .2
		else:
			new_connection.global_position = first_element_position # + direction * .2
		if atoms[second_index].get_node("Atom Symbol") and atoms[second_index].get_node("Atom Symbol").text != "":
			height -= distance * .2
		new_connection.scale.x = height
		new_connection.look_at(second_element_position)
		
		var new_bond = Bond.new(new_connection, atoms[first_index], atoms[second_index])
		bonds.append(new_bond)

# Determines the appropriate scene to instantiate based on the bond type.
func get_connection(bond_type):
	if bond_type == "1.0":
		return SINGLE_BOND.instantiate()
	if bond_type == "2.0":
		return DOUBLE_BOND.instantiate()
	if bond_type == "3.0":
		return TRIPLE_BOND.instantiate()
	if bond_type == "1.5":
		return ARROMATIC_BOND.instantiate()
	return SINGLE_BOND.instantiate()

# Loads and adds rings based on a configuration file.
func add_rings():
	var base_path = ProjectSettings.globalize_path("res://")
	var rings_file = FileAccess.open(base_path + "rings.txt",FileAccess.READ)
	var rings_data = rings_file.get_as_text().split("\n")
	for ring in rings_data:
		var elements = ring.strip_edges().split(" ")
		rings.append(elements)

# Handler for button press actions, possibly to change scenes or trigger functions.
func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")

# Updates global color selection based on user choice from an option button.
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

# Toggles highlighting of connected atoms and bonds, ensuring exclusive selection with ring highlighting.
func _on_neighbors_pressed():
	clear_connected_highlights()
	if neighbors_checkbox.button_pressed:
		rings_checkbox.button_pressed = false
		highlight_connected()

# Toggles highlighting of atoms and bonds in rings, ensuring exclusive selection with neighbor highlighting.
func _on_rings_pressed():
	clear_connected_highlights()
	if rings_checkbox.button_pressed:
		neighbors_checkbox.button_pressed = false
		highlight_rings()


func _on_index_toggle_toggled(toggled_on):
	if toggled_on:
		turn_on_index()
	else:
		turn_off_index()
