extends Node

@onready var base_path = ProjectSettings.globalize_path("res://")
@onready var output_log = FileAccess.open(base_path + "output_logs.txt", FileAccess.WRITE)

const RED = Color8(255, 0, 0)
const GREEN = Color8(0, 255, 0)
const PURPLE = Color8(160, 32, 240)
const YELLOW = Color8(255,255,0)

signal modulate_highlight(color_code: Color)
signal download_failed(output_logs)
signal install_venv()

var venv_thread = Thread.new()
var venv_exists = false
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_venv()
	install_venv.connect(_on_setup_venv)

func _on_setup_venv():
	venv_thread.start(_setup_venv_thread)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_venv():
	if check_if_venv_exists():
		print("Virtual environment already exists.")
		output_log.store_string("Virtual environment already exists.\n")
		venv_exists = true
		return

func _setup_venv_thread():
	#var executables = ["python", "python3", "python3.11"]
	var executables = ["python3.11", "python3", "python"]
	var args = ["-m", "venv", ".venv"]
	var output = []
	var error = 1 # Initialize with a non-OK value
	for executable in executables:
		output.clear() # Clear previous output
		error = OS.execute(executable, args, output, true, true)
		if error == OK:
			print(executable + " used to create virtual environment.")
			output_log.store_string(executable + " used to create virtual environment.\n")
			install_libraries(executable)
			venv_exists = true
			print("Virtual environment created successfully.")
			output_log.store_string(executable + " used to create virtual environment.\n")
			return # Exit the function upon success
		else:
			print("Attempt with " + executable + " failed.")
			output_log.store_string("Attempt with " + executable + " failed.\n")
			print(output)
			output_log.store_string(str(output) + "\n")
			for line in output:
				if "ensurepip" in line:
					download_failed.emit(output)
					return
	if error != OK:
		print("Failed to create virtual environment with any Python executable.")
		output_log.store_string("Failed to create virtual environment with any Python executable.\n")


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
	var error = OS.execute(pip_path, args, output, true, true)
	if error == OK:
		print("Libraries installed successfully.")
		output_log.store_string("Libraries installed successfully.\n")
		for line in output:
			print(line)
			output_log.store_string(line + "\n")
	else:
		print("Failed to install libraries.")
		output_log.store_string("Failed to install libraries.\n")
		print(error)
		output_log.store_string(str(error) + "\n")
		print(output)
		output_log.store_string(str(output) + "\n")

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
