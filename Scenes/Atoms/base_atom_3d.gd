extends CSGSphere3D

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

const BASE_COLOR = Color(Globals.NEON_GREEN, .5)
var highlight_color = Color(Globals.NEON_GREEN, .5)

func _ready():
	highlight.hide()
	atom_index.hide()
	Globals.modulate_highlight.connect(_on_modulate_highlight)
	Globals.camera_position.connect(_on_camera_position)
	material = material.duplicate()

func _on_modulate_highlight():
	highlight.modulate = Color(Globals.selected_color, .1)

func update_atom(atom_type:String, charge: int, index: int):
	atom_charge.visible = false
	atom_index.text = str(index)
	var atom_material: Material = get_material()
	if atom_type == "C":
		atom_symbol.text = ""
		atom_material.albedo_color = WHITE
		return
	atom_symbol.text = atom_type
	atom_type = atom_type.capitalize().strip_edges()
	# Color text
	if atom_type in ["H"]:
		atom_symbol.modulate = WHITE
		atom_material.albedo_color = WHITE
	elif atom_type in ["N"]:
		atom_symbol.modulate = BLUE
		atom_material.albedo_color = BLUE
	elif atom_type in ["O"]:
		atom_symbol.modulate = RED
		atom_material.albedo_color = RED
	elif atom_type in ["F", "Cl"]:
		atom_symbol.modulate = GREEN
		atom_material.albedo_color = GREEN
	elif atom_type in ["Br"]:
		atom_symbol.modulate = DARK_RED
		atom_material.albedo_color = DARK_RED
	elif atom_type in ["I"]:
		atom_symbol.modulate = DARK_VIOLET
		atom_material.albedo_color = DARK_VIOLET
	elif atom_type in ["He", "Ne", "Ar", "Kr", "Xe"]:
		atom_symbol.modulate = CYAN
		atom_material.albedo_color = CYAN
	elif atom_type in ["P"]:
		atom_symbol.modulate = ORANGE
		atom_material.albedo_color = ORANGE
	elif atom_type in ["S"]:
		atom_symbol.modulate = YELLOW
		atom_material.albedo_color = YELLOW
	elif atom_type in "B":
		atom_symbol.modulate = BEIGE
		atom_material.albedo_color = BEIGE
	elif atom_type in ["Li", "Na", "K", "Rb", "Cs", "Fr"]:
		atom_symbol.modulate = VIOLET
		atom_material.albedo_color = VIOLET
	elif atom_type in ["Be", "Mg", "Ca", "Sr", "Ba", "Ra"]:
		atom_symbol.modulate = DARK_GREEN
		atom_material.albedo_color = DARK_GREEN
	elif atom_type in ["Ti"]:
		atom_symbol.modulate = GRAY
		atom_material.albedo_color = GRAY
	elif atom_type in ["Fe"]:
		atom_symbol.modulate = DARK_ORANGE
		atom_material.albedo_color = DARK_ORANGE
	else:
		atom_symbol.modulate = PINK
		atom_material.albedo_color = PINK
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

func _on_camera_position(camera_pos: Vector3):
	look_at(camera_pos)


func _on_static_body_3d_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and  event.button_index == 1 and event.pressed == true:
		Globals.node_clicked.emit(self)

func turn_off_index():
	if atom_index.text != "":
		atom_index.hide()

func turn_on_index():
	if atom_index.text != "":
		atom_index.show()
