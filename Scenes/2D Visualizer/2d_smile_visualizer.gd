extends Node2D

const DOUBLE_BOND = preload("res://Scenes/Bonds/double_bond.tscn")
const SINGLE_BOND = preload("res://Scenes/Bonds/single_bond.tscn")
const TRIPLE_BOND = preload("res://Scenes/Bonds/triple_bond.tscn")
const ARROMATIC_BOND = preload("res://Scenes/Bonds/arromatic_bond.tscn")
const BASE_ATOM = preload("res://Scenes/Atoms/base_atom.tscn")
const SELECTED = preload("res://Scenes/2D Visualizer/selected.tres")

@onready var structure = $Structure
@onready var h_box_container = $"Control/SMILES Container/ScrollContainer/HBoxContainer"
@onready var check_box = $Control/Options/CheckBox
@onready var viewport = get_viewport_rect().size

@onready var back = $Control/Back
@onready var option_button = $Control/Options/HBoxContainer/OptionButton

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

func _on_update_colors():
	back.add_theme_color_override("font_color", Globals.selected_color)
	option_button.add_theme_color_override("font_color", Globals.selected_color)
	
	var stylebox = generate_theme_stylebox()
	for button in atom_buttons:
		button.add_theme_stylebox_override("pressed", stylebox)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
		var atom_node = BASE_ATOM.instantiate()
		structure.add_child(atom_node)
		atom_node.global_position = Vector2(x_position, y_position)
		atoms.append(atom_node)
		atom_node.update_atom(symbol)

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
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		
		var height = distance
		var new_connection = get_connection(bond_type)
		structure.add_child(new_connection)
		print(first_index, " lol ", second_index)
		print("First Atom:", atoms[first_index].get_node("Label").text)
		print("Second Atom:", atoms[second_index].get_node("Label").text)
		if atoms[first_index].get_node("Label") and atoms[first_index].get_node("Label").text != "":
			new_connection.global_position = first_element_position + direction * .2
			height -= distance * .2
		else:
			new_connection.global_position = first_element_position # + direction * .2
		if atoms[second_index].get_node("Label") and atoms[second_index].get_node("Label").text != "":
			height -= distance * .2
		new_connection.scale.x = height
		new_connection.look_at(second_element_position)
		
		var new_bond = Bond.new(new_connection, atoms[first_index], atoms[second_index])
		bonds.append(new_bond)


func get_connection(bond_type):
	print(bond_type)
	if bond_type == "1.0":
		return SINGLE_BOND.instantiate()
	if bond_type == "2.0":
		return DOUBLE_BOND.instantiate()
	if bond_type == "3.0":
		return TRIPLE_BOND.instantiate()
	if bond_type == "1.5":
		return ARROMATIC_BOND.instantiate()
	return SINGLE_BOND.instantiate()

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
