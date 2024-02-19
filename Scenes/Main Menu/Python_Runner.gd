extends Control

var system_ready = false
@onready var smiles_input = $"Options/Inputs/Smiles Input"
@onready var _3d = $"Options/Inputs/VBoxContainer/3D"
@onready var _2d = $"Options/Inputs/VBoxContainer/2D"
@onready var python_install = $"Python Install"

@onready var color_buttons = [$Options/Colors/Red, $Options/Colors/Yellow, $Options/Colors/Green, $Options/Colors/Purple]
# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.venv_exists:
		_3d.disabled = true
		_2d.disabled = true
		python_install.visible = true
	Globals.download_failed.connect(_on_download_failed)
	Globals.modulate_highlight.connect(_on_update_colors)

func _on_update_colors():
	$Text/Title
	$"Options/Inputs/Smiles Input"
	$"Options/Inputs/VBoxContainer/2D"
	$"Options/Inputs/VBoxContainer/3D"
	$"Python Install"
	$Github
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not system_ready and Globals.venv_exists:
		_2d.disabled = false
		_3d.disabled = false
		system_ready = true
		python_install.visible = false

func _on_two_d_pressed():
	if Globals.venv_exists:
		_2d.disabled = true
		await Globals.run_python_script("rdkit_script.py", [smiles_input.text])
		print("After running")
		get_tree().change_scene_to_file("res://Scenes/2D Visualizer/2d_smile_visualizer.tscn")
	else:
		print("Wait, Venv is not ready yet")

func _on_three_d_pressed():
	if Globals.venv_exists:
		_3d.disabled = false
		await Globals.run_python_script("rdkit_script.py", [smiles_input.text])
		get_tree().change_scene_to_file("res://Scenes/3D Visualizer/3d_smile_visualizer.tscn")
	else:
		print("Wait, Venv is not ready yet")

func _on_download_failed(output_log: Array):
	var new_alert = AcceptDialog.new()
	new_alert.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	add_child.call_deferred(new_alert)
	new_alert.show()
	new_alert.title = "Error - App will now close"
	new_alert.size = Vector2i(500, 500)
	new_alert.always_on_top = true
	new_alert.popup_window = true
	var output_string = "\n".join(output_log)
	new_alert.dialog_text = output_string
	new_alert.confirmed.connect(func():
		get_tree().quit()
	)


func _on_python_install_pressed():
	Globals.install_venv.emit()

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
			continue
		button.button_pressed = false
