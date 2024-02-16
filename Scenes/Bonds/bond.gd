extends Node
class_name Bond

var bond : Node2D = null
var connected_atoms : Array = []


func _init(itself, atom1, atom2):
	bond = itself
	connected_atoms.append(atom1)
	connected_atoms.append(atom2)
	Globals.modulate_highlight.connect(_on_modulate_highlight)
	bond.get_node("Highlight").hide()

func _on_modulate_highlight(highlight_color: Color):
	bond.get_node("Highlight").color = highlight_color
	
func check_if_connected_atoms(atoms: Array):
	if connected_atoms[0] in atoms and connected_atoms[1] in atoms:
		return true
	return false

func check_if_contains_atoms(atoms: Array):
	if connected_atoms[0] in atoms or connected_atoms[1] in atoms:
		return true
	return false

func turn_on_highlight():
	bond.get_node("Highlight").show()


func turn_off_highlight():
	bond.get_node("Highlight").hide()
