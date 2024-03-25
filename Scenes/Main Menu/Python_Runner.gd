extends Control

var system_ready = false
@onready var smiles_input = $"Options/Inputs/Smiles Input"
@onready var _3d = $"Options/Inputs/VBoxContainer/3D"
@onready var _2d = $"Options/Inputs/VBoxContainer/2D"
@onready var python_install = $"Python Install"
@onready var title = $Text/Title
@onready var github = $Github
@onready var output = $Options/Output
@onready var exit = $Options/Exit

@onready var color_buttons = [$Options/Colors/Red, $Options/Colors/Yellow, $Options/Colors/Green, $Options/Colors/Purple]
# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.venv_exists:
		_3d.disabled = true
		_2d.disabled = true
		python_install.visible = true
		output.text = "No python virtual environment\nfound"
	Globals.modulate_highlight.connect(_on_update_colors)
	Globals.modulate_highlight.emit()
	_on_enter_colors()

func _on_enter_colors():
	var selected_button = null
	if Globals.selected_color == Globals.NEON_RED:
		selected_button = color_buttons[0]
	elif  Globals.selected_color == Globals.NEON_YELLOW:
		selected_button = color_buttons[1]
	elif  Globals.selected_color == Globals.NEON_GREEN:
		selected_button = color_buttons[2]
	elif  Globals.selected_color == Globals.NEON_PURPLE:
		selected_button = color_buttons[3]
	else:
		selected_button = color_buttons[2]
	toggle_off_color_buttons(selected_button)


func _on_update_colors():
	title.add_theme_color_override("font_color", Globals.selected_color)
	smiles_input.add_theme_color_override("font_color", Globals.selected_color)
	smiles_input.add_theme_color_override("font_placeholder_color", Globals.selected_color)
	_2d.add_theme_color_override("font_color", Globals.selected_color)
	_3d.add_theme_color_override("font_color", Globals.selected_color)
	python_install.add_theme_color_override("font_color", Globals.selected_color)
	github.add_theme_color_override("font_color", Globals.selected_color)
	exit.add_theme_color_override("font_color", Globals.selected_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not system_ready and Globals.venv_exists:
		_2d.disabled = false
		_3d.disabled = false
		system_ready = true
		python_install.visible = false
		output.text = ""

func _on_two_d_pressed():
	if smiles_input.text == "":
		output.text = "Enter a smiles"
		return
	if Globals.venv_exists:
		_2d.disabled = false
		var ran = await Globals.run_python_script("rdkit_script.py", [smiles_input.text])
		if ran is bool and ran == false:
			output.text = "Invalid SMILES String"
		else:
			get_tree().change_scene_to_file("res://Scenes/2D Visualizer/2d_smile_visualizer.tscn")
	else:
		output.text = "Wait, Venv is not ready yet"

func _on_three_d_pressed():
	if smiles_input.text == "":
		output.text = "Enter a smiles"
		return
	if Globals.venv_exists:
		_3d.disabled = false
		await Globals.run_python_script("rdkit_script.py", [smiles_input.text])
		# Check file for elements
		#var base_path = ProjectSettings.globalize_path("res://")
		#var elements_file = FileAccess.open(base_path + "elements.txt",FileAccess.READ)
		var ran = await Globals.run_python_script("rdkit_script.py", [smiles_input.text])
		if ran is bool and ran == false:
			output.text = "Invalid SMILES String"
		else:
			get_tree().change_scene_to_file("res://Scenes/3D Visualizer/3d_smile_visualizer.tscn")
	else:
		output.text = "Wait, Venv is not ready yet"

func _on_python_install_pressed():
	get_tree().change_scene_to_file("res://Scenes/Python Installation/python_installer.tscn")

func _on_red_pressed():
	var selected_button = color_buttons[0]
	Globals.selected_color = Globals.NEON_RED
	toggle_off_color_buttons(selected_button)
	Globals.modulate_highlight.emit()

func _on_yellow_pressed():
	var selected_button = color_buttons[1]
	Globals.selected_color = Globals.NEON_YELLOW
	toggle_off_color_buttons(selected_button)
	Globals.modulate_highlight.emit()


func _on_green_pressed():
	var selected_button = color_buttons[2]
	Globals.selected_color = Globals.NEON_GREEN
	toggle_off_color_buttons(selected_button)
	Globals.modulate_highlight.emit()


func _on_purple_pressed():
	var selected_button = color_buttons[3]
	Globals.selected_color = Globals.NEON_PURPLE
	toggle_off_color_buttons(selected_button)
	Globals.modulate_highlight.emit()

func toggle_off_color_buttons(selected_button):
	for button in color_buttons:
		if button == selected_button:
			button.button_pressed = true
			continue
		button.button_pressed = false


func _on_exit_pressed():
	get_tree().quit()
