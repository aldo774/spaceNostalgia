extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var max_value
var current_value

onready var stamina = get_node("stamina")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func init(max_value, current_value):
	self.max_value = max_value
	self.current_value = clamp(current_value, 0, max_value)
	
	
func update(value):
	if value >= -0.05 and value <= 1:
		stamina.set_scale(Vector2(value, 1))
	
func get_staminabar_len():
	return stamina.get_scale().x