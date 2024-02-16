GDPC                �                                                                      $   X   res://.godot/exported/133200997/export-400d1eff53905ade4bce2ffd44fcf427-single_bond.scn �v      �      �����yW{���w}    X   res://.godot/exported/133200997/export-698068851540e84026f4dcaaa9eccf03-base_atom.scn   �O      K      ����*�(��/g7=xT    \   res://.godot/exported/133200997/export-729b187323c671d61f0633d611a32919-python_runner.scn   p�      %      �y7dL��;�[���    X   res://.godot/exported/133200997/export-731a88ae6e29ce98ea5880a93347c481-double_bond.scn �r            /LX�Y^!��#a�f�    X   res://.godot/exported/133200997/export-83e9e4a6394957b39ec424af4e0bf006-triple_bond.scn @z      Q      VT���?:�y�C@    T   res://.godot/exported/133200997/export-936b8a2781d1e04326b627936a941293-circle.scn   �            w���/O��%ԔfN    T   res://.godot/exported/133200997/export-93c4c4002ef000946d0fbddae6ebb2eb-selected.res�'      R      ��SSJ���&q��    `   res://.godot/exported/133200997/export-b3e7c33bd64b870cf03b21d0096ab1e2-3d_smile_visualizer.scn `5      K      �	?��q?�D�#���A.    \   res://.godot/exported/133200997/export-b5ec1e58fd7a2d39506bdd7296df99bf-arromatic_bond.scn  �g      e      P;�B��U*#�<���    `   res://.godot/exported/133200997/export-d1bbbce0375388431daff4c93f20f208-2d_smile_visualizer.scn       �      4Ѐ��x\*�an�    ,   res://.godot/global_script_class_cache.cfg  0�      �       [�}�mF�g^f��|    H   res://.godot/imported/circle.png-3ef6f736add1256eacd8c5e81d8bd060.ctex  �U      �      ��&����WX#�:�    L   res://.godot/imported/highlight.png-42ed1ef274efef6c12e23c2896b8bdb4.ctex   `^      �      Z�%� ����D��ZU    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex �      �      �Yz=������������       res://.godot/uid_cache.bin  ��      c      �[<������C�KR    4   res://Scenes/2D Visualizer/2d_smile_visualizer.gd                 דJ<`��ېb]��    <   res://Scenes/2D Visualizer/2d_smile_visualizer.tscn.remap   Э      p       ؘl�$(Di(梀0d    0   res://Scenes/2D Visualizer/selected.tres.remap  @�      e       ��/���5IT
�S�h    4   res://Scenes/3D Visualizer/3d_smile_visualizer.gd    +      S
      �'{c]s�de�D��_    <   res://Scenes/3D Visualizer/3d_smile_visualizer.tscn.remap   ��      p       �c|{�	���l@�        res://Scenes/Atoms/base_atom.gd �E      �	      .!�3U�/�i�=��1�    (   res://Scenes/Atoms/base_atom.tscn.remap  �      f       ڽe7��{�rNv���    $   res://Scenes/Atoms/circle.png.import�]      �       +���+�-�j&6��a�    (   res://Scenes/Atoms/highlight.png.import g      �       ���B�x��Y>v���    ,   res://Scenes/Bonds/arromatic_bond.tscn.remap��      k       �rA9��hD����"�Q       res://Scenes/Bonds/bond.gd  Po      %      ��?�%t؄�PG�--A    ,   res://Scenes/Bonds/double_bond.tscn.remap    �      h       ���,�8�^�2im�å    ,   res://Scenes/Bonds/single_bond.tscn.remap   p�      h       ��ƥQ������l�!�    ,   res://Scenes/Bonds/triple_bond.tscn.remap   �      h       ��ǻ�1M�q���Y�    (   res://Scenes/Main Menu/Python_Runner.gd �~      �      f�g��G]DS[%�$�    0   res://Scenes/Main Menu/python_runner.tscn.remap P�      j       �mf�����m���       res://Utils/globals.gd  ��      R      ʇODְ�q}Ab���.       res://circle.tscn.remap ��      c       �Q��Ӱ���U��U�       res://icon.svg  ��      �      C��=U���^Qu��U3       res://icon.svg.import    �      �       �}V� �*ac-���       res://project.binary�      �      /�A���h;G^Kb�R҈            extends Node2D

const DOUBLE_BOND = preload("res://Scenes/Bonds/double_bond.tscn")
const SINGLE_BOND = preload("res://Scenes/Bonds/single_bond.tscn")
const TRIPLE_BOND = preload("res://Scenes/Bonds/triple_bond.tscn")
const ARROMATIC_BOND = preload("res://Scenes/Bonds/arromatic_bond.tscn")
const BASE_ATOM = preload("res://Scenes/Atoms/base_atom.tscn")
const SELECTED = preload("res://Scenes/2D Visualizer/selected.tres")
@onready var structure = $Structure
@onready var h_box_container = $"Control/SMILES Container/ScrollContainer/HBoxContainer"
@onready var check_box = $Control/Options/CheckBox
@onready var viewport = get_viewport_rect().size

var atoms = []
var bonds = []

var highlighted_atoms = []
var highlighted_bonds = []
var highlighted_connected_atoms = []
var highlighted_connected_bonds = []
var atom_buttons = []


var ctrl_pressed = false
# Called when the node enters the scene tree for the first time.
func _ready():
	add_elements()
	add_connections()
	generate_smiles_array()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("multi-select"):
		print("Ctrl Pressed Now")
		ctrl_pressed = true
	if Input.is_action_just_released("multi-select"):
		ctrl_pressed = false

func contains_alpha_char(characters: String) -> bool:
	for character in characters:
		if is_alpha(character):
			return true
	return false

func is_alpha(character: String) -> bool:
	if character.length() == 0:
		return false
	var code = character[0].to_ascii_buffer()[0]
	return (code >= 'a'.to_ascii_buffer()[0] and code <= 'z'.to_ascii_buffer()[0]) or (code >= 'A'.to_ascii_buffer()[0] and code <= 'Z'.to_ascii_buffer()[0])

func generate_smiles_array():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "smiles.txt",FileAccess.READ)
	var elements_text = elements_file.get_as_text().strip_edges()
	var elements = elements_text.split(" ")
	
	for element in elements:
		var new_button = Button.new()
		new_button.add_theme_font_size_override("font_size", 50)
		new_button.add_theme_stylebox_override("pressed", SELECTED)
		new_button.toggle_mode = true
		new_button.text = str(element)
		h_box_container.add_child(new_button)
		if contains_alpha_char(element):
			atom_buttons.append(new_button)
			new_button.pressed.connect(update_buttons.bind(new_button))
		else:
			new_button.disabled = true

func update_buttons(button_node):
	if ctrl_pressed:
		update_highlights()
		return
	for button in atom_buttons:
		if button == button_node:
			continue
		button.button_pressed = false
	update_highlights()

func update_highlights():
	for atom in highlighted_atoms:
		atom.turn_off_highlight.call_deferred()
	for bond in highlighted_bonds:
		bond.turn_off_highlight.call_deferred()
	highlighted_atoms.clear()
	highlighted_bonds.clear()
	for idx in atom_buttons.size():
		if atom_buttons[idx].button_pressed == true:
			var current_atom = atoms[idx]
			current_atom.turn_on_highlight.call_deferred()
			highlighted_atoms.append(current_atom)
	for bond in bonds:
		if bond.check_if_connected_atoms(highlighted_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_bonds.append(bond)
	clear_connected_highlights()
	if check_box.button_pressed:
		highlight_connected()

func highlight_connected():
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()
	for bond in bonds:
		if bond.check_if_contains_atoms(highlighted_atoms):
			bond.turn_on_highlight.call_deferred()
			highlighted_connected_bonds.append(bond)
			for atom in bond.connected_atoms:
				atom.turn_on_highlight.call_deferred()
				highlighted_connected_atoms.append(atom)

func clear_connected_highlights():
	for atom in highlighted_connected_atoms:
		if atom in highlighted_atoms:
			continue
		atom.turn_off_highlight()
	for bond in highlighted_connected_bonds:
		if bond in highlighted_bonds:
			continue
		bond.turn_off_highlight()
	highlighted_connected_atoms.clear()
	highlighted_connected_bonds.clear()

func add_elements():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "two_d_elements.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" ", false)
		var symbol = split_data[0]
		var index = split_data[1]
		var x_position = float(split_data[2]) - viewport.x * .5
		var y_position = float(split_data[3]) - viewport.y * .5
		var atom_node = BASE_ATOM.instantiate()
		structure.add_child(atom_node)
		atom_node.global_position = Vector2(x_position, y_position)
		atoms.append(atom_node)
		atom_node.update_atom.call_deferred(symbol)

func add_connections():
	var base_path = ProjectSettings.globalize_path("res://")
	var elements_file = FileAccess.open(base_path + "connections.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" - ", false)
		var first_index = int(split_data[0])
		var second_index = int(split_data[1])
		var bond_type = split_data[2]
		var first_element_position = atoms[first_index].global_position
		var second_element_position = atoms[second_index].global_position
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		
		var new_connection = get_connection(bond_type)
		structure.add_child(new_connection)
		new_connection.global_position = first_element_position + direction * .2
		new_connection.scale.x = distance - distance * .4
		new_connection.look_at(second_element_position)
		
		var new_bond = Bond.new(new_connection, atoms[first_index], atoms[second_index])
		bonds.append(new_bond)


func get_connection(bond_type):
	print(bond_type)
	if bond_type == "1.0":
		return SINGLE_BOND.instantiate()
	if bond_type == "2.0":
		return DOUBLE_BOND.instantiate()
	if bond_type == "3.0":
		return TRIPLE_BOND.instantiate()
	if bond_type == "1.5":
		return ARROMATIC_BOND.instantiate()
	return SINGLE_BOND.instantiate()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")

func _on_option_button_item_selected(index):
	if index == 0:
		Globals.modulate_highlight.emit(Globals.RED)
	if index == 1:
		Globals.modulate_highlight.emit(Globals.PURPLE)
	if index == 2:
		Globals.modulate_highlight.emit(Globals.GREEN)
	if index == 3:
		Globals.modulate_highlight.emit(Globals.YELLOW)


func _on_check_box_pressed():
	clear_connected_highlights()
	if check_box.button_pressed:
		highlight_connected()
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script 2   res://Scenes/2D Visualizer/2d_smile_visualizer.gd ��������      local://PackedScene_hu1it )         PackedScene          	         names "   <      2D SMILE Visualizer    script    Node2D    Control    custom_minimum_size    layout_mode    anchors_preset    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical    metadata/_edit_lock_ 
   ColorRect    z_index    z_as_relative    Button    anchor_left $   theme_override_font_sizes/font_size    text    SMILES Container 
   alignment    VBoxContainer    ScrollContainer    size_flags_horizontal    size_flags_vertical    HBoxContainer    Label !   theme_override_colors/font_color    horizontal_alignment    vertical_alignment    Options    OptionButton    item_count 	   selected    popup/item_0/text    popup/item_0/id    popup/item_1/text    popup/item_1/id    popup/item_2/text    popup/item_2/id    popup/item_3/text    popup/item_3/id 	   CheckBox )   theme_override_colors/font_pressed_color '   theme_override_colors/font_hover_color /   theme_override_colors/font_hover_pressed_color '   theme_override_colors/font_focus_color *   theme_override_colors/font_disabled_color )   theme_override_colors/font_outline_color 
   Structure 	   Camera2D    _on_button_pressed    pressed     _on_option_button_item_selected    item_selected    _on_check_box_pressed    	   variants    '             
     �D  4D                 �?      �     ��      D     �C               ����                  ��     pA     p�     hB                   Go Back             ?     ��     �B     �B
     /D  �B                       �?      Hold Ctrl To Multi-Select      EC     �B      Select Highlight Color       Red       Purple       Green       Yellow    	��>	��>	��>  �?      Highlight Neighbors       node_count             nodes       ��������       ����                            ����                                 	      
                     	      	      
                    ����	                                          	      	      
                    ����                           	      
                                                     ����	                           	                     	                          ����            	                                ����            	                                      ����      	                      !                    "   ����         	      
                                   ����      	                           #   #   ����      	   $      %      &   !   '      (   "   )      *   #   +   	   ,   $   -                 .   .   ����	      	         /   %   0      1      2      3      4         &                  5   ����                6   6   ����      
             conn_count             conns               8   7              
       :   9                     8   ;                    node_paths              editable_instances              version             RSRC     RSRC                    StyleBoxFlat            ��������                                                  resource_local_to_scene    resource_name    content_margin_left    content_margin_top    content_margin_right    content_margin_bottom 	   bg_color    draw_center    skew    border_width_left    border_width_top    border_width_right    border_width_bottom    border_color    border_blend    corner_radius_top_left    corner_radius_top_right    corner_radius_bottom_right    corner_radius_bottom_left    corner_detail    expand_margin_left    expand_margin_top    expand_margin_right    expand_margin_bottom    shadow_color    shadow_size    shadow_offset    anti_aliasing    anti_aliasing_size    script           local://StyleBoxFlat_hn3p3          StyleBoxFlat          ��k?    ���>  �?      RSRC              extends Node3D

var atoms = []
@onready var structure = $Structure
var holding_left_click = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_elements()
	add_connections()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed == true:
			holding_left_click = true
		if event.button_index == 1 and event.pressed == false:
			holding_left_click = false
	if event is InputEventMouseMotion:
		if not holding_left_click:
			return
		var mouse_position = event.relative
		structure.rotate_x(.01 * mouse_position.y)
		structure.rotate_y(.01 * mouse_position.x)


func add_elements():
	var elements_file = FileAccess.open("elements.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" ", false)
		var symbol = split_data[0]
		var index = split_data[1]
		var x_position = float(split_data[2]) * 1
		var y_position = float(split_data[3]) * 1
		var z_position = float(split_data[4]) * 1
		var atom_node = CSGSphere3D.new()
		structure.add_child(atom_node)
		atom_node.global_position = Vector3(x_position, y_position, z_position)
		atoms.append(atom_node)

func add_connections():
	var elements_file = FileAccess.open("connections.txt",FileAccess.READ)
	var elements = elements_file.get_as_text().split("\n")
	for element in elements:
		if element.length() == 0:
			continue
		var split_data = element.split(" - ", false)
		var first_index = int(split_data[0])
		var second_index = int(split_data[1])
		var first_element_position = atoms[first_index].global_position
		var second_element_position = atoms[second_index].global_position
		
		var new_connection = CSGCylinder3D.new()
		structure.add_child(new_connection)
		new_connection.radius = .1
		
		var direction = second_element_position - first_element_position
		var distance = direction.length()
		new_connection.height = distance
		
		var normalized_direction = direction.normalized()
		var connection_up_vector = Vector3(0, 1, 0)
		if normalized_direction.cross(connection_up_vector).length() == 0:
			connection_up_vector = Vector3(0, 0, 1)
		var connection_quaternion = Quaternion(connection_up_vector, normalized_direction)
		new_connection.transform = Transform3D(connection_quaternion, first_element_position + normalized_direction * distance * .5)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Main Menu/python_runner.tscn")
             RSRC                    PackedScene            ��������                                            r      resource_local_to_scene    resource_name    sky_top_color    sky_horizon_color 
   sky_curve    sky_energy_multiplier 
   sky_cover    sky_cover_modulate    ground_bottom_color    ground_horizon_color    ground_curve    ground_energy_multiplier    sun_angle_max 
   sun_curve    use_debanding    script    sky_material    process_mode    radiance_size    background_mode    background_color    background_energy_multiplier    background_intensity    background_canvas_max_layer    background_camera_feed_id    sky    sky_custom_fov    sky_rotation    ambient_light_source    ambient_light_color    ambient_light_sky_contribution    ambient_light_energy    reflected_light_source    tonemap_mode    tonemap_exposure    tonemap_white    ssr_enabled    ssr_max_steps    ssr_fade_in    ssr_fade_out    ssr_depth_tolerance    ssao_enabled    ssao_radius    ssao_intensity    ssao_power    ssao_detail    ssao_horizon    ssao_sharpness    ssao_light_affect    ssao_ao_channel_affect    ssil_enabled    ssil_radius    ssil_intensity    ssil_sharpness    ssil_normal_rejection    sdfgi_enabled    sdfgi_use_occlusion    sdfgi_read_sky_light    sdfgi_bounce_feedback    sdfgi_cascades    sdfgi_min_cell_size    sdfgi_cascade0_distance    sdfgi_max_distance    sdfgi_y_scale    sdfgi_energy    sdfgi_normal_bias    sdfgi_probe_bias    glow_enabled    glow_levels/1    glow_levels/2    glow_levels/3    glow_levels/4    glow_levels/5    glow_levels/6    glow_levels/7    glow_normalized    glow_intensity    glow_strength 	   glow_mix    glow_bloom    glow_blend_mode    glow_hdr_threshold    glow_hdr_scale    glow_hdr_luminance_cap    glow_map_strength 	   glow_map    fog_enabled    fog_light_color    fog_light_energy    fog_sun_scatter    fog_density    fog_aerial_perspective    fog_sky_affect    fog_height    fog_height_density    volumetric_fog_enabled    volumetric_fog_density    volumetric_fog_albedo    volumetric_fog_emission    volumetric_fog_emission_energy    volumetric_fog_gi_inject    volumetric_fog_anisotropy    volumetric_fog_length    volumetric_fog_detail_spread    volumetric_fog_ambient_inject    volumetric_fog_sky_affect -   volumetric_fog_temporal_reprojection_enabled ,   volumetric_fog_temporal_reprojection_amount    adjustment_enabled    adjustment_brightness    adjustment_contrast    adjustment_saturation    adjustment_color_correction 	   _bundled       Script 2   res://Scenes/3D Visualizer/3d_smile_visualizer.gd ��������   $   local://ProceduralSkyMaterial_kwslx          local://Sky_4b45j a         local://Environment_jv7ab �         local://PackedScene_ubq0f �         ProceduralSkyMaterial          �p%?;�'?F�+?  �?	      �p%?;�'?F�+?  �?         Sky                          Environment                         !         C                  PackedScene    q      	         names "         3D SMILE Visualizer    script    Node3D    WorldEnvironment    environment    DirectionalLight3D 
   transform    shadow_enabled 	   Camera3D 
   Structure    Button    anchors_preset    anchor_left    anchor_right    offset_left    offset_bottom    grow_horizontal $   theme_override_font_sizes/font_size    text    _on_button_pressed    pressed    	   variants                             г]��ݾ  �>       ?г]?   �  @?�ݾ                       �?              �?              �?           A           �?      �      A                   Go Back       node_count             nodes     D   ��������       ����                            ����                           ����                                 ����                        	   ����                
   
   ����                                    	      
                   conn_count             conns                                      node_paths              editable_instances              version             RSRC     extends Node2D

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
RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script     res://Scenes/Atoms/base_atom.gd ��������
   Texture2D !   res://Scenes/Atoms/highlight.png k�ԋ$
   Texture2D    res://Scenes/Atoms/circle.png cӊ.'Q~      local://PackedScene_kb5ib �         PackedScene          	         names "      
   Base Atom    z_index    z_as_relative    script    Node2D 
   Highlight 	   modulate    scale    texture 	   Sprite2D    Label    custom_minimum_size    anchors_preset    anchor_left    anchor_top    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical $   theme_override_font_sizes/font_size    text    horizontal_alignment    vertical_alignment    	   variants                                   �?  �?      �?   ����
   ���=���=         
   ��L=��L=         
     `A  `A            ?     ��     �@         
         O       node_count             nodes     P   ��������       ����                                  	      ����                                             	   	   ����                           
   
   ����      	      
                                                                                                   conn_count              conns               node_paths              editable_instances              version             RSRC     GST2            ����                        |  RIFFt  WEBPVP8Lg  /��?p䶍$��ߞ���*�!�ֶ��ަ��m۶m۶mۻc�m��n�6:�:M���& �������7�r�y1C�T�HDɢ����CW���n�Na���=z�P�V��ahq.��������@Qd=��{՞�����s�`�B3�5�cvm���&Ӣ1�2�+��v���s�c��MuG��Dm�n��1�O*�<�=�`+G�eYN?Ņ�c�+=U=���R<Pi�yDAǥx���p����y����б1���e���$���T�J4�dJxME��_�cYă�Hv��H�0S�1�z�N���QN4��I���QL!����c8��T4R�dM��<4Vn��`6�Kr�i{�h�dq�oN1�h�8��[Ӕ��ʍċF�-�vW�QА��QhO�Pјyĩ�#p4h�l5�C�G����`3���i�lZl��4p7B/
��S�m����Ρ�&h|Bcg�p������ځ���U���sG��HP�i�P��y|�{��4~.����A
QB.#��7�ȩ�S�Bq�
=�j���#T"��\V?� ���a=�PL�
��/^�����p��\F��=
ʮ�J��E0R�%�2u�QTv%W1����"�l(+�k����dZAj�V���V�>�6����AqI�e���r-)"�{�c(��[�y
�����X��F$}��"����T�G��lD�����Y�k�B�q�׈�H
]�*�Ys�����hȭ�Z�f���o�j�Q�����p�۟_����N=ԛj�w�C~~'���7��T3������f<�OLx3�6��G��~��O\�(
�SUǍ|gk6��;�IxG�^@ݩ�����z9�_D����Q� t�<�*��� ���E;?ĵ��ڎ@i�D��н��V׳�=ݩ����d�'Nj=��z�zd�zV�B�G����� �����ԣʨ�I�G_��_=�o���X���z��P�-_��Y�
��t���) Jn;<ю|}k',���g�'s;�@�v:�$��� <W� �3 ��W9@9� �I�3��&��Z�W7/�h#���o���l*��$Wc���[ͳj�T3���lFe��s3��Y_����A>5�j_�`q�d·�J(��Wt,�`*}������!��#?$�k�J� 6���7��"[-�~we����`������yK��_ V�/�\�(+J�K�a��$����u2�"pAF%"\���J6^��i�N{�����]�U�H�Cm�B���e�a��GE�>���6I�#�f�����60ZvwaA����*��&lel�%��E"���Up`Q]�U�²�6�K���2�"�.��.lE������LX��o�5`q��jX
˛���;x�@�,|���'wL]x�J��&�Cuc� k	{h�N��� <��!�����G+�iz-�����f�	�WKut��5d�glQK����ԁcj|a��s�L8lT���jɆ��ج��ò	���lʤpKa�ʊ$ωb$lY�IS��6M��=#Y�þ�$M�`纳��B{WIy6�ɰ}I�aQNh6i.��3�%�w&K�tN�LD�pR]��i��	pVE]'�B�.p^��P��3:C��$�����&�k3��4V��pw��39B>�H��*x��K��0C�����j�Q#���[E�Qj�#�,Dha�*��{I&�Lu�?0WZ��)���WA��}�~	�1�;�=�pDI3��>a���J0l���wA�j0suG}�'&0����,�
��U�AB���Z����1L�R���!��#����	�U5���b��b���aQ�Ho��k�.Lp\             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://d24oiyt1w8krr"
path="res://.godot/imported/circle.png-3ef6f736add1256eacd8c5e81d8bd060.ctex"
metadata={
"vram_texture": false
}
              GST2            ����                        j  RIFFb  WEBPVP8LV  /��?w��mۄ?�moz�?�
۶Aq
En�6�)��`�)�΁��A� �����4�`P�����E�����O�c$���Yx�.�L_���S����,��Ƴ����h�[n�5�Fr-�-��R�z!���ef��9��5����F�$�f����9��<uCf���<3�~�Fc�k�F�ч��v6�Cf��ِ��k���d9���#��Si�����F��|zp��w/�|�\'�M�8}n�; ��7^Xbv'>��[�/�(e=c�"����Z�C�Wi�l�)���
�^h�*�J3����m]#_��yw�G�CGWI�	S<K��'�\uCI�|�R)?trm�`NIf�Q~h��t,2Ge~�����폘�����,���#3�[z8�j�g���_��cW>���6���kͥ$sx�V���5�@^���k��D�#�KN�7�i#�z$uξ�cZ�\�������$��$��a�i(��%U�q���H���L[��S�$f�<�X�6J^��1����.��s�H3�%}�-V����_��+�Ǵ�;%b�[u�i2�*���)δ�x�X�֚d��~�
�;Ŵ�ԯb����l��b�q���S�;Ŵ�Sb��5��bm_?�v����e�--�l՚bO���5%�֓ljߪ�L�W�k%Q��D��ڳ��@�����b���;�@��~;�(���z�cF�lj-��>Ko�A��a��LZ�ZgC��z�es�08�tYT��%���~�D-ϒy���y�Z!�@�(ς�F��&����9�`�?�7W]X�x9n�kd^�⛛KZ��rZE�/�_��8��x9l+C'�_�\x�]�Y��� f7�0ɽ�P��|�3�i��xa4�?L=;���f,���63�fM��o�a�.�S��q��\���H}\gF�A�a��O\��Z"�Rl~�!�0Z�~A�]W�^7�"�L��?�)�V
�
��t��"���4b�u$I/��N�1�����Y�#jd���"j'E�����R�x-vv�.�v�w�i�/��GoV=���"ן5��ͬr���&���&�f�SNԆ��3؝ �n�(���D/�{A�v�o��T�@����c���ޅ�]���-�f��[z�޳��=���8z�O�}J������+�^����)zO��[��ޭz��ݸ�ޅc��F�{z;�Ы�g����%v/��؅�F�%:���6�ڈ���&�&�Kx�(�\��Dn0�(rG�ꑫ���Ą/�n�v�8�p��k���W���K�b-��H���]5��(����|�a6F���ʔ�K�q�(�Y�f����+M�*��)���'����~A�K�Fk�x�6���O����.����䊓H%�͠!���gкN�:~Fh�	2iN��]DiQ�	(uL���G~fP;F��3U�BKn~��>���d]|".~f�V|��|����
p?~&+��6���d�kd^���.d����5�ˤK�k�?��\\��f�&s^��~���Y���I`M�3x̸�Y�q4��Y�Z�h%���b@2�_@b�/����1b�ŧ�ݑF!�C2�{��Y^W��K2���_ >miIT��%���j����̮6%�.�$�}mM�\�U���;�o�n��~}���׵���SzvJ>�O��J��v���A�i�f��T�lʴU�߀%[eS�M�<�$�R���a�j�k�==�W"�r-�P�@6�:�֝�	�lJ�v��&��dS���uf~�|��}�K/�K���$�J���3:2�A:�����J�-�����b�{��z���s�+�sJ[�taj�稣���2���5����å5s�Q>�l���3K��F|����c߲3-�3��|��9ϣv������c�Y;<d0�}�9&��᥋�n�_��CuƗN����=	�_�9�a䋺��4�񥥣�g*���TO��K[���fԒ��+%��*����c=ed������K�[�Иo�._PQ��p�.���"2�F�����`��OMD����L^z~A��v4�2w/ãg�׸�T�42_Վ�������h4ˊE�ѧӡ�3��U>"r���               [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://psq8t3ocnca2"
path="res://.godot/imported/highlight.png-42ed1ef274efef6c12e23c2896b8bdb4.ctex"
metadata={
"vram_texture": false
}
            RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_uh67n �          PackedScene          	         names "         Arromatic Bond    Node2D 
   Highlight    z_index    z_as_relative    color    polygon 
   Polygon2D    Line2D2 	   position    points    width    default_color    Line2D    Dotted Line    Line2D3    Line2D4    Line2D5    Line2D6    Line2D7    Line2D8    Line2D9 	   Line2D10    	   variants          ����            �?  �?      �?%            ��      �@  �?  �@  �?  ��
          @%                �?          @                 �?
          �%      ��L=    ���=    %      ��>    ��L>    %        �>    ���>    %      33�>    ���>    %      ff�>       ?    %      ��?    ��?    %      ff&?    333?    %        @?    ��L?    %      ��Y?    fff?    %      33s?      �?          node_count             nodes     �   ��������       ����                      ����                                              ����   	      
                                    ����   	                       ����   
   	                                ����   
   
                                ����   
                                   ����   
                                   ����   
                                   ����   
                                   ����   
                                   ����   
                                   ����   
                                   ����   
                            conn_count              conns               node_paths              editable_instances              version             RSRC           extends Node
class_name Bond

var bond : Node2D = null
var connected_atoms : Array = []


func _init(itself, atom1, atom2):
	bond = itself
	connected_atoms.append(atom1)
	connected_atoms.append(atom2)
	Globals.modulate_highlight.connect(_on_modulate_highlight)
	bond.get_node("Highlight").hide()

func _on_modulate_highlight(highlight_color: Color):
	bond.get_node("Highlight").color = highlight_color
	
func check_if_connected_atoms(atoms: Array):
	if connected_atoms[0] in atoms and connected_atoms[1] in atoms:
		return true
	return false

func check_if_contains_atoms(atoms: Array):
	if connected_atoms[0] in atoms or connected_atoms[1] in atoms:
		return true
	return false

func turn_on_highlight():
	bond.get_node("Highlight").show()


func turn_off_highlight():
	bond.get_node("Highlight").hide()
           RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_h4l41 �          PackedScene          	         names "         Double Bond    Node2D 
   Highlight    z_index    z_as_relative    color    polygon 
   Polygon2D    Line2D 	   position    points    width    default_color    Line2D2    	   variants    	      ����            �?  �?      �?%            ��      �@  �?  �@  �?  ��
          @%                �?          @                 �?
          �      node_count             nodes     4   ��������       ����                      ����                                              ����   	      
                                    ����   	      
                            conn_count              conns               node_paths              editable_instances              version             RSRC               RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_ml04i �          PackedScene          	         names "         Single Bond    Node2D 
   Highlight    z_index    z_as_relative    color    polygon 
   Polygon2D    Line2D    points    width    default_color    	   variants          ����            �?  �?      �?%            ��      �@  �?  �@  �?  ��%                �?         �@                 �?      node_count             nodes     #   ��������       ����                      ����                                              ����   	      
                      conn_count              conns               node_paths              editable_instances              version             RSRC    RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script           local://PackedScene_6jaxy �          PackedScene          	         names "         Triple Bond    Node2D 
   Highlight    z_index    z_as_relative    color    polygon 
   Polygon2D    Line2D    points    width    default_color    Line2D2 	   position    Line2D3    	   variants    	      ����            �?  �?      �?%            ��      �@  �?  �@  �?  ��%                �?         �?                 �?
          �
          @      node_count             nodes     A   ��������       ����                      ����                                              ����   	      
                              ����         	      
                              ����         	      
                      conn_count              conns               node_paths              editable_instances              version             RSRC               extends Control

var system_ready = false
@onready var smiles_input = $"HBoxContainer/Smiles Input"
@onready var _3d = $"HBoxContainer/VBoxContainer/3D"
@onready var _2d = $"HBoxContainer/VBoxContainer/2D"
# Called when the node enters the scene tree for the first time.
func _ready():
	if not Globals.venv_exists:
		_3d.disabled = true
		_2d.disabled = true
	Globals.download_failed.connect(_on_download_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not system_ready and Globals.venv_exists:
		_2d.disabled = false
		_3d.disabled = false
		system_ready = true

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
          RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script (   res://Scenes/Main Menu/Python_Runner.gd ��������      local://PackedScene_8da3j          PackedScene          	         names "   "      Python_Runner    layout_mode    anchors_preset    anchor_right    anchor_bottom    grow_horizontal    grow_vertical    script    Control 
   ColorRect    Title    anchor_left    offset_left    offset_right    offset_bottom !   theme_override_colors/font_color $   theme_override_font_sizes/font_size    text    Label    HBoxContainer    anchor_top    offset_top    Smiles Input    custom_minimum_size    placeholder_text    caret_blink 	   TextEdit    VBoxContainer    3D    Button    2D    _on_three_d_pressed    pressed    _on_two_d_pressed    	   variants                        �?                                  ?     ��     �A     �A                 �?   �         SMILES Visualizer            ��     �     �C     B
     �C       #         Enter Smiles       
     HC  HB   
   3D Visual    
   2D Visual       node_count             nodes     �   ��������       ����                                                          	   	   ����                                                      
   ����                                    	      
                                             ����                                                                                            ����                                                  ����                          ����                                      ����                               conn_count             conns                                            !                    node_paths              editable_instances              version             RSRC           extends Node

@onready var base_path = ProjectSettings.globalize_path("res://")
@onready var output_log = FileAccess.open(base_path + "output_logs.txt", FileAccess.WRITE)

const RED = Color8(255, 0, 0)
const GREEN = Color8(0, 255, 0)
const PURPLE = Color8(160, 32, 240)
const YELLOW = Color8(255,255,0)

signal modulate_highlight(color_code: Color)
signal download_failed(output_logs)

var venv_thread = Thread.new()
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
		output_log.store_string("Virtual environment already exists.\n")
		venv_exists = true
		return
	venv_thread.start(_setup_venv_thread)

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
	var current_directory = DirAccess.open("res://")
	return current_directory.dir_exists(".venv")


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
              RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script    
   Texture2D    res://Scenes/Atoms/circle.png cӊ.'Q~      local://PackedScene_v88po          PackedScene          	         names "      
   Base Atom    Node2D 	   Sprite2D    scale    texture    Label    custom_minimum_size    anchors_preset    anchor_right    anchor_bottom    offset_left    offset_top    offset_right    offset_bottom    grow_horizontal    grow_vertical    	   variants       
   ���=���=          
     �A  �A           �?      �            node_count             nodes     -   ��������       ����                      ����                                 ����
                     	      
                                              conn_count              conns               node_paths              editable_instances              version             RSRC GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح����mow�*��f�&��Cp�ȑD_��ٮ}�)� C+���UE��tlp�V/<p��ҕ�ig���E�W�����Sթ�� ӗ�A~@2�E�G"���~ ��5tQ#�+�@.ݡ�i۳�3�5�l��^c��=�x�Н&rA��a�lN��TgK㼧�)݉J�N���I�9��R���$`��[���=i�QgK�4c��%�*�D#I-�<�)&a��J�� ���d+�-Ֆ
��Ζ���Ut��(Q�h:�K��xZ�-��b��ٞ%+�]�p�yFV�F'����kd�^���:[Z��/��ʡy�����EJo�񷰼s�ɿ�A���N�O��Y��D��8�c)���TZ6�7m�A��\oE�hZ�{YJ�)u\a{W��>�?�]���+T�<o�{dU�`��5�Hf1�ۗ�j�b�2�,%85�G.�A�J�"���i��e)!	�Z؊U�u�X��j�c�_�r�`֩A�O��X5��F+YNL��A��ƩƗp��ױب���>J�[a|	�J��;�ʴb���F�^�PT�s�)+Xe)qL^wS�`�)%��9�x��bZ��y
Y4�F����$G�$�Rz����[���lu�ie)qN��K�<)�:�,�=�ۼ�R����x��5�'+X�OV�<���F[�g=w[-�A�����v����$+��Ҳ�i����*���	�e͙�Y���:5FM{6�����d)锵Z�*ʹ�v�U+�9�\���������P�e-��Eb)j�y��RwJ�6��Mrd\�pyYJ���t�mMO�'a8�R4��̍ﾒX��R�Vsb|q�id)	�ݛ��GR��$p�����Y��$r�J��^hi�̃�ūu'2+��s�rp�&��U��Pf��+�7�:w��|��EUe�`����$G�C�q�ō&1ŎG�s� Dq�Q�{�p��x���|��S%��<
\�n���9�X�_�y���6]���մ�Ŝt�q�<�RW����A �y��ػ����������p�7�l���?�:������*.ո;i��5�	 Ύ�ș`D*�JZA����V^���%�~������1�#�a'a*�;Qa�y�b��[��'[�"a���H�$��4� ���	j�ô7�xS�@�W�@ ��DF"���X����4g��'4��F�@ ����ܿ� ���e�~�U�T#�x��)vr#�Q��?���2��]i�{8>9^[�� �4�2{�F'&����|���|�.�?��Ȩ"�� 3Tp��93/Dp>ϙ�@�B�\���E��#��YA 7 `�2"���%�c�YM: ��S���"�+ P�9=+D�%�i �3� �G�vs�D ?&"� !�3nEФ��?Q��@D �Z4�]�~D �������6�	q�\.[[7����!��P�=��J��H�*]_��q�s��s��V�=w�� ��9wr��(Z����)'�IH����t�'0��y�luG�9@��UDV�W ��0ݙe)i e��.�� ����<����	�}m֛�������L ,6�  �x����~Tg����&c�U��` ���iڛu����<���?" �-��s[�!}����W�_�J���f����+^*����n�;�SSyp��c��6��e�G���;3Z�A�3�t��i�9b�Pg�����^����t����x��)O��Q�My95�G���;w9�n��$�z[������<w�#�)+��"������" U~}����O��[��|��]q;�lzt�;��Ȱ:��7�������E��*��oh�z���N<_�>���>>��|O�׷_L��/������զ9̳���{���z~����Ŀ?� �.݌��?�N����|��ZgO�o�����9��!�
Ƽ�}S߫˓���:����q�;i��i�]�t� G��Q0�_î!�w��?-��0_�|��nk�S�0l�>=]�e9�G��v��J[=Y9b�3�mE�X�X�-A��fV�2K�jS0"��2!��7��؀�3���3�\�+2�Z`��T	�hI-��N�2���A��M�@�jl����	���5�a�Y�6-o���������x}�}t��Zgs>1)���mQ?����vbZR����m���C��C�{�3o��=}b"/�|���o��?_^�_�+��,���5�U��� 4��]>	@Cl5���w��_$�c��V��sr*5 5��I��9��
�hJV�!�jk�A�=ٞ7���9<T�gť�o�٣����������l��Y�:���}�G�R}Ο����������r!Nϊ�C�;m7�dg����Ez���S%��8��)2Kͪ�6̰�5�/Ӥ�ag�1���,9Pu�]o�Q��{��;�J?<�Yo^_��~��.�>�����]����>߿Y�_�,�U_��o�~��[?n�=��Wg����>���������}y��N�m	n���Kro�䨯rJ���.u�e���-K��䐖��Y�['��N��p������r�Εܪ�x]���j1=^�wʩ4�,���!�&;ج��j�e��EcL���b�_��E�ϕ�u�$�Y��Lj��*���٢Z�y�F��m�p�
�Rw�����,Y�/q��h�M!���,V� �g��Y�J��
.��e�h#�m�d���Y�h�������k�c�q��ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[          [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bj5uuirc7e5uc"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                [remap]

path="res://.godot/exported/133200997/export-d1bbbce0375388431daff4c93f20f208-2d_smile_visualizer.scn"
[remap]

path="res://.godot/exported/133200997/export-93c4c4002ef000946d0fbddae6ebb2eb-selected.res"
           [remap]

path="res://.godot/exported/133200997/export-b3e7c33bd64b870cf03b21d0096ab1e2-3d_smile_visualizer.scn"
[remap]

path="res://.godot/exported/133200997/export-698068851540e84026f4dcaaa9eccf03-base_atom.scn"
          [remap]

path="res://.godot/exported/133200997/export-b5ec1e58fd7a2d39506bdd7296df99bf-arromatic_bond.scn"
     [remap]

path="res://.godot/exported/133200997/export-731a88ae6e29ce98ea5880a93347c481-double_bond.scn"
        [remap]

path="res://.godot/exported/133200997/export-400d1eff53905ade4bce2ffd44fcf427-single_bond.scn"
        [remap]

path="res://.godot/exported/133200997/export-83e9e4a6394957b39ec424af4e0bf006-triple_bond.scn"
        [remap]

path="res://.godot/exported/133200997/export-729b187323c671d61f0633d611a32919-python_runner.scn"
      [remap]

path="res://.godot/exported/133200997/export-936b8a2781d1e04326b627936a941293-circle.scn"
             list=Array[Dictionary]([{
"base": &"Node",
"class": &"Bond",
"icon": "",
"language": &"GDScript",
"path": "res://Scenes/Bonds/bond.gd"
}])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             ��2��M03   res://Scenes/2D Visualizer/2d_smile_visualizer.tscn͐�&�bG(   res://Scenes/2D Visualizer/selected.tres��hfh5q3   res://Scenes/3D Visualizer/3d_smile_visualizer.tscn���
G�!   res://Scenes/Atoms/base_atom.tscncӊ.'Q~   res://Scenes/Atoms/circle.pngk�ԋ$    res://Scenes/Atoms/highlight.png<D&^��x&   res://Scenes/Bonds/arromatic_bond.tscn��i�}y#   res://Scenes/Bonds/double_bond.tscn��!�*�y#   res://Scenes/Bonds/single_bond.tscn�EiOC#   res://Scenes/Bonds/triple_bond.tscn9��^�MBF)   res://Scenes/Main Menu/python_runner.tscnl�T�9��F   res://circle.tscn�2����*   res://icon.svg             ECFG	      application/config/name         RDKIT Visualier    application/run/main_scene4      )   res://Scenes/Main Menu/python_runner.tscn      application/config/features$   "         4.2    Forward Plus       application/config/icon         res://icon.svg     autoload/Globals          *res://Utils/globals.gd "   display/window/size/viewport_width         #   display/window/size/viewport_height      �     display/window/stretch/mode         canvas_items   input/multi-select�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script                 