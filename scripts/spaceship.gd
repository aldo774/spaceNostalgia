extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var init_robo = get_node('robo')
onready var stamina_bar = get_node("staminabar")
onready var robo = preload('res://scenes/robo.tscn')

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	stamina_bar.init(100, 100)
	var robo_1 = robo.instance()
	init_robo.add_child(robo_1)
	robo_1.set_pos(Vector2(370.654297, 470.130341))