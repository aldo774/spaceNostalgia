extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var stamina_bar = get_node("staminabar")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	stamina_bar.init(100, 100)
	