extends Button

var element_name: String
var element_index: int
@onready var element_index_text = $"Element Index Text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_theme_stylebox_override("pressed", generate_theme_stylebox())
	self.text = str(element_name)
	self.element_index_text.text = str(element_index)
	turn_off_index()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func generate_theme_stylebox():
	var new_stylebox = StyleBoxFlat.new()
	new_stylebox.bg_color = Color(Globals.selected_color, .5)
	return new_stylebox

func turn_off_index():
	if element_index_text.text != "":
		element_index_text.hide()

func turn_on_index():
	if element_index_text.text != "":
		element_index_text.show()
