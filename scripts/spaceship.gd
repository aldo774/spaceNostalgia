extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var stamina_bar = get_node("staminabar")

func _fixed_process(delta):
	var jump = Input.is_action_pressed("jump")
	
	var stamina = stamina_bar.get_staminabar_len()
	
	if jump:
		stamina_bar.update(stamina-.01)
	else:
		stamina_bar.update(stamina+.02)

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	stamina_bar.init(100, 100)
	