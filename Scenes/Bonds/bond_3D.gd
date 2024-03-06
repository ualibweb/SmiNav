extends Node
class_name Bond_3D

var bond : Node3D = null
var connected_atoms : Array = []
var highlight_node : Node3D = null


func _init(itself, atom1, atom2):
	bond = itself
	connected_atoms.append(atom1)
	connected_atoms.append(atom2)
	Globals.modulate_highlight.connect(_on_modulate_highlight)
	highlight_node = bond.get_node("Highlight")
	for child in highlight_node.get_children():
		child.material = child.material.duplicate()
		child.transparency = .8
	if highlight_node:
		highlight_node.hide()

func _on_modulate_highlight():
	if highlight_node != null:
		for child in highlight_node.get_children():
			child.material.albedo_color = Globals.selected_color
			child.transparency = .8
	
func check_if_connected_atoms(atoms: Array):
	if connected_atoms[0] in atoms and connected_atoms[1] in atoms:
		return true
	return false

func check_if_contains_atoms(atoms: Array):
	if connected_atoms[0] in atoms or connected_atoms[1] in atoms:
		return true
	return false

func check_if_hydrogen_connected(atoms: Array):
	if connected_atoms[0] in atoms and connected_atoms[1].label.text == "H":
		return connected_atoms[1]
	elif connected_atoms[1] in atoms and connected_atoms[0].label.text == "H":
		return connected_atoms[0]
	return null

func turn_on_highlight():
	if highlight_node != null:
		highlight_node.show()


func turn_off_highlight():
	if highlight_node != null:
		highlight_node.hide()
