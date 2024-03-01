extends Control

@onready var title = $Text/Title
@onready var rich_text_label = $Text/RichTextLabel
@onready var back = $Back

var venv_thread = Thread.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.modulate_highlight.connect(_on_update_colors)
	Globals.modulate_highlight.emit()
	venv_thread.start(_setup_venv_thread)

func _on_update_colors():
	title.add_theme_color_override("font_color", Globals.selected_color)
	rich_text_label.add_theme_color_override("default_color", Globals.selected_color)
	back.add_theme_color_override("font_color", Globals.selected_color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _setup_venv_thread():
	#var executables = ["python", "python3", "python3.11"]
	var executables = ["python3.11", "python3", "python"]
	var args = ["-m", "venv", ".venv"]
	var output = []
	var error = 1 # Initialize with a non-OK value
	for executable in executables:
		output.clear() # Clear previous output
		rich_text_label.add_text.call_deferred("Installing Python via " + executable + " " + " ".join(args) + "\n")
		error = OS.execute(executable, args, output, true, false)
		for line in output:
			rich_text_label.add_text.call_deferred(line)
		if error == OK:
			print(executable + " used to create virtual environment.")
			rich_text_label.add_text.call_deferred(executable + " used to create virtual environment.\n")
			install_libraries(executable)
			Globals.venv_exists = true
			rich_text_label.add_text.call_deferred("Virtual environment created successfully.\n")
			return # Exit the function upon success
		else:
			print("Attempt with " + executable + " failed.")
			rich_text_label.add_text.call_deferred("Attempt with " + executable + " failed.\n")
			print(output)
			for line in output:
				if "ensurepip" in line:
					return
	if error != OK:
		print("Failed to create virtual environment with any Python executable.\n")
		rich_text_label.add_text.call_deferred("Failed to create virtual environment with any Python executable.\n")


func install_libraries(executable):
	var venv_path = ProjectSettings.globalize_path("res://.venv")
	var os_name = OS.get_name()
	var pip_path = ""
	if os_name == "Windows":
		pip_path = venv_path + "/Scripts/pip"
	else:
		pip_path = venv_path + "/bin/pip"
	var libraries = ["rdkit"]
	var args = ["install"] + libraries
	var output = []
	rich_text_label.add_text.call_deferred("Installing libraries via " + pip_path + " " + " ".join(args) + "\n")
	var error = OS.execute(pip_path, args, output, true, false)
	for line in output:
		rich_text_label.add_text.call_deferred(line)
	if error == OK:
		print("Libraries installed successfully.")
		rich_text_label.add_text.call_deferred("Libraries installed successfully.\n")
		for line in output:
			print(line)
	else:
		print("Failed to install libraries.")
		rich_text_label.add_text.call_deferred("Failed to install libraries.\n")
		print(error)
		print(output)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")
