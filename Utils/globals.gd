extends Node

@onready var base_path = ProjectSettings.globalize_path("res://")

const NEON_GREEN = Color8(15, 255, 80)
const NEON_RED = Color8(255, 49, 49)
const NEON_YELLOW = Color8(255, 255, 51)
const NEON_PURPLE = Color8(157, 0, 255)

const RED = Color8(255, 0, 0)
const GREEN = Color8(0, 255, 0)
const PURPLE = Color8(160, 32, 240)
const YELLOW = Color8(255,255,0)

signal modulate_highlight(color_code: Color)

var selected_color = NEON_GREEN

var venv_exists = false
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_venv()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_venv():
	if check_if_venv_exists():
		print("Virtual environment already exists.")
		venv_exists = true
		return


func check_if_venv_exists() -> bool:
	var current_directory = DirAccess.open(base_path + ".venv/")
	print(current_directory)
	if current_directory:
		return true
	return false


func run_python_script(python_script_path, arguments):
	var python_executable = base_path + ".venv/bin/python"
	print(python_executable)
	var script_path = base_path + python_script_path
	var python_arguments = arguments
	var args = [script_path] + python_arguments
	var output = []
	var error = OS.execute(python_executable, args, output, true, true)
	for line in output:
		print(line)
	if error == OK:
		print("Command executed successfully.")
		for line in output:
			print(line)
	else:
		print("Failed to execute command.")
		print(error)
	print("Finished")
	return output
