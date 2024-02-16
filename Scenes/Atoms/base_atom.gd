extends Node2D

@onready var label = $Label
@onready var sprite_2d = $Sprite2D
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
	Globals.modulate_highlight.connect(_on_modulate_highlight)

func _on_modulate_highlight(highlight_color: Color):
	highlight.modulate = highlight_color

func update_atom(atom_type:String):
	if atom_type == "C":
		sprite_2d.visible = true
		label.text = ""
		return
	label.text = atom_type
	sprite_2d.visible = false
	atom_type = atom_type.capitalize().strip_edges()
	print(atom_type)
	# Color text
	if atom_type in ["H"]:
		label.add_theme_color_override("font_color", WHITE)
	elif atom_type in ["N"]:
		label.add_theme_color_override("font_color", BLUE)
	elif atom_type in ["O"]:
		label.add_theme_color_override("font_color", RED)
	elif atom_type in ["F", "Cl"]:
		label.add_theme_color_override("font_color", GREEN)
	elif atom_type in ["Br"]:
		label.add_theme_color_override("font_color", DARK_RED)
	elif atom_type in ["I"]:
		label.add_theme_color_override("font_color", DARK_VIOLET)
	elif atom_type in ["He", "Ne", "Ar", "Kr", "Xe"]:
		label.add_theme_color_override("font_color", CYAN)
	elif atom_type in ["P"]:
		label.add_theme_color_override("font_color", ORANGE)
	elif atom_type in ["S"]:
		label.add_theme_color_override("font_color", YELLOW)
	elif atom_type in "B":
		label.add_theme_color_override("font_color", BEIGE)
	elif atom_type in ["Li", "Na", "K", "Rb", "Cs", "Fr"]:
		label.add_theme_color_override("font_color", VIOLET)
	elif atom_type in ["Be", "Mg", "Ca", "Sr", "Ba", "Ra"]:
		label.add_theme_color_override("font_color", DARK_GREEN)
	elif atom_type in ["Ti"]:
		label.add_theme_color_override("font_color", GRAY)
	elif atom_type in ["Fe"]:
		label.add_theme_color_override("font_color", DARK_ORANGE)
	else:
		label.add_theme_color_override("font_color", PINK)
	print(label.get_theme_color("font_color"))

func turn_on_highlight():
	highlight.show()

func turn_off_highlight():
	highlight.hide()
