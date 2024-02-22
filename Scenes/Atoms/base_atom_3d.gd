extends CSGSphere3D

@onready var label = $Label3D
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

const BASE_COLOR = Color(Globals.NEON_GREEN, .5)
var highlight_color = Color(Globals.NEON_GREEN, .5)

func _ready():
	highlight.hide()
	Globals.modulate_highlight.connect(_on_modulate_highlight)
	Globals.camera_position.connect(_on_camera_position)
	material = material.duplicate()

func _on_modulate_highlight():
	highlight.modulate = Color(Globals.selected_color, .1)

func update_atom(atom_type:String):
	print(atom_type)
	var atom_material: Material = get_material()
	if atom_type == "C":
		label.text = ""
		atom_material.albedo_color = WHITE
		return
	label.text = atom_type
	atom_type = atom_type.capitalize().strip_edges()
	# Color text
	if atom_type in ["H"]:
		label.modulate = WHITE
		atom_material.albedo_color = WHITE
	elif atom_type in ["N"]:
		label.modulate = BLUE
		atom_material.albedo_color = BLUE
	elif atom_type in ["O"]:
		label.modulate = RED
		atom_material.albedo_color = RED
	elif atom_type in ["F", "Cl"]:
		label.modulate = GREEN
		atom_material.albedo_color = GREEN
	elif atom_type in ["Br"]:
		label.modulate = DARK_RED
		atom_material.albedo_color = DARK_RED
	elif atom_type in ["I"]:
		label.modulate = DARK_VIOLET
		atom_material.albedo_color = DARK_VIOLET
	elif atom_type in ["He", "Ne", "Ar", "Kr", "Xe"]:
		label.modulate = CYAN
		atom_material.albedo_color = CYAN
	elif atom_type in ["P"]:
		label.modulate = ORANGE
		atom_material.albedo_color = ORANGE
	elif atom_type in ["S"]:
		label.modulate = YELLOW
		atom_material.albedo_color = YELLOW
	elif atom_type in "B":
		label.modulate = BEIGE
		atom_material.albedo_color = BEIGE
	elif atom_type in ["Li", "Na", "K", "Rb", "Cs", "Fr"]:
		label.modulate = VIOLET
		atom_material.albedo_color = VIOLET
	elif atom_type in ["Be", "Mg", "Ca", "Sr", "Ba", "Ra"]:
		label.modulate = DARK_GREEN
		atom_material.albedo_color = DARK_GREEN
	elif atom_type in ["Ti"]:
		label.modulate = GRAY
		atom_material.albedo_color = GRAY
	elif atom_type in ["Fe"]:
		label.modulate = DARK_ORANGE
		atom_material.albedo_color = DARK_ORANGE
	else:
		label.modulate = PINK
		atom_material.albedo_color = PINK

func turn_on_highlight():
	highlight.show()

func turn_off_highlight():
	highlight.hide()

func _on_camera_position(camera_pos: Vector3):
	look_at(camera_pos)
