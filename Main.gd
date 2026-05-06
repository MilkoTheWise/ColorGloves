extends Node

var _lib = null
var gloves = preload("res://Items/Clothing/Gloves_Leather/Files/MT_Gloves_Leather.tres")
var gloves2 = preload("res://Items/Clothing/Gloves_Work/Gloves_Work.tres")
var color_button = ColorPickerButton.new()
var SAVE_PATH = "user://glove_color.cfg"
var handsSlot = _lib._caller.interface.equipmentUI.get_child(14)

func _ready():
    load_glove_color()
    if Engine.has_meta("RTVModLib"):
        var lib = Engine.get_meta("RTVModLib")
        if lib._is_ready:
            _on_lib_ready()
        else:
            lib.frameworks_ready.connect(_on_lib_ready)

func _on_lib_ready():
    _lib = Engine.get_meta("RTVModLib")
    _lib.hook("interface-open-pre", Open)
    print("------------Reached Lib Ready---------------")

func Open():
    var Destination: GridContainer = _lib._caller.get_node_or_null("Tools/Buttons/Margin/Buttons")
    if not is_instance_valid(Destination): return
    if is_instance_valid(color_button) and color_button.get_parent() != null:
        if not is_instance_valid(color_button.get_parent()):
            color_button.get_parent().remove_child(color_button)
    if not is_instance_valid(color_button):
        color_button = ColorPickerButton.new()
        color_button.custom_minimum_size = Vector2(246, 34)
        color_button.color = gloves.get_shader_parameter("tint")
    if not Destination:
        printerr("Error: Destination container not found!")
        return
    if color_button.get_parent() == null:
        color_button.custom_minimum_size = Vector2(246, 34)
        Destination.add_child(color_button)
        color_button.color = gloves.get_shader_parameter("tint")
        if not color_button.color_changed.is_connected(glovesChanged):
            color_button.color_changed.connect(glovesChanged)

func glovesChanged(new_color):
    gloves.set_shader_parameter("tint", new_color) # Set the shader parameter on gloves with that color
    gloves2.material.set_shader_parameter("tint", new_color)
    save_glove_color(new_color)

func save_glove_color(color: Color):
    var config = ConfigFile.new()
    config.set_value("Visuals", "glove_tint", color)
    config.save(SAVE_PATH)

func load_glove_color():
    var config = ConfigFile.new()
    var err = config.load(SAVE_PATH)
    if err == OK:
        var saved_color = config.get_value("Visuals", "glove_tint", Color.WHITE)
        gloves.set_shader_parameter("tint", saved_color)
        gloves2.material.set_shader_parameter("tint", saved_color)
        color_button.color = saved_color
        print("Loaded saved glove color.")
