extends Node2D

@onready var atom_symbol = $"Atom Symbol"
@onready var atom_charge = $"Atom Symbol/Atom Charge"
@onready var atom_index = $"Atom Symbol/Atom Index"
@onready var highlight = $Highlight


# Colors
const WHITE = Color8(255,255,255)
const BLACK = Color8(0,0,0)
const RED = Color8(255, 0, 0)
const GREEN = Color8(0, 255, 0)
const BLUE = Color8(0, 0, 255)
const DARK_RED = Color8(139,0,0)
const DARK_VIOLET = Color8(148,0,211)
const CYAN = Color8(0,255,255)
const ORANGE = Color8(255,165,0)
const YELLOW = Color8(255,255,0)
const BEIGE = Color8(245,245,220)
const VIOLET = Color8(238,130,238)
const DARK_GREEN = Color8(0,100,0)
const GRAY = Color8(128,128,128)
const DARK_ORANGE = Color8(255,140,0)
const PINK = Color8(255,192,203)

func _ready():
	highlight.hide()
	atom_index.hide()
	Globals.modulate_highlight.connect(_on_modulate_highlight)

func _on_modulate_highlight():
	highlight.modulate = Color(Globals.selected_color, .5)

func update_atom(atom_type:String, charge: int, index):
	atom_charge.visible = false
	atom_index.text = str(index)
	if atom_type == "C":
		atom_symbol.text = ""
		return
	atom_symbol.text = atom_type
	atom_type = atom_type.capitalize().strip_edges()
	# Color text
	if atom_type in ["H"]:
		atom_symbol.add_theme_color_override("font_color", WHITE)
	elif atom_type in ["N"]:
		atom_symbol.add_theme_color_override("font_color", BLUE)
	elif atom_type in ["O"]:
		atom_symbol.add_theme_color_override("font_color", RED)
	elif atom_type in ["F", "Cl"]:
		atom_symbol.add_theme_color_override("font_color", GREEN)
	elif atom_type in ["Br"]:
		atom_symbol.add_theme_color_override("font_color", DARK_RED)
	elif atom_type in ["I"]:
		atom_symbol.add_theme_color_override("font_color", DARK_VIOLET)
	elif atom_type in ["He", "Ne", "Ar", "Kr", "Xe"]:
		atom_symbol.add_theme_color_override("font_color", CYAN)
	elif atom_type in ["P"]:
		atom_symbol.add_theme_color_override("font_color", ORANGE)
	elif atom_type in ["S"]:
		atom_symbol.add_theme_color_override("font_color", YELLOW)
	elif atom_type in "B":
		atom_symbol.add_theme_color_override("font_color", BEIGE)
	elif atom_type in ["Li", "Na", "K", "Rb", "Cs", "Fr"]:
		atom_symbol.add_theme_color_override("font_color", VIOLET)
	elif atom_type in ["Be", "Mg", "Ca", "Sr", "Ba", "Ra"]:
		atom_symbol.add_theme_color_override("font_color", DARK_GREEN)
	elif atom_type in ["Ti"]:
		atom_symbol.add_theme_color_override("font_color", GRAY)
	elif atom_type in ["Fe"]:
		atom_symbol.add_theme_color_override("font_color", DARK_ORANGE)
	else:
		atom_symbol.add_theme_color_override("font_color", PINK)
	atom_charge.visible = true
	if charge == 0:
		atom_charge.visible = false
	elif charge == -1:
		atom_charge.text = "-"
	elif charge == 1:
		atom_charge.text = "+"
	else:
		atom_charge.text = str(charge)

func turn_on_highlight():
	highlight.show()

func turn_off_highlight():
	highlight.hide()


func _on_static_body_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed == true:
		Globals.node_clicked.emit(self)

func turn_off_index():
	if atom_index.text != "":
		atom_index.hide()

func turn_on_index():
	if atom_index.text != "":
		atom_index.show()
