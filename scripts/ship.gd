
extends KinematicBody2D

# This is a simple collision demo showing how
# the kinematic controller works.
# move() will allow to move the node, and will
# always move it to a non-colliding spot,
# as long as it starts from a non-colliding spot too.

# Member variables
const GRAVITY = 350.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 10
const WALK_MAX_SPEED = 170
const STOP_FORCE = 1300
const JUMP_SPEED = 150

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

const TIPO = 'CENARIO'

var velocity = Vector2()
var on_air_time = 100
var jumping_animation = false
var animating_jump = false
var is_exploding = false
var max_damage_supported = 2
var time_to_charge_again = 10
var velocity_on_collision = 0

onready var stamina_bar = get_node("../staminabar")
#onready var enemies = preload("res://scenes/robo.tscn").get_nodes_in_group("inimigo")

func _fixed_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	var stamina = stamina_bar.get_staminabar_len()
	var walk_left = Input.is_action_pressed("move_left")
	var walk_right = Input.is_action_pressed("move_right")
	var jump = Input.is_action_pressed("jump")
	
	var stop = true
	
	if (walk_left and velocity.y and not is_exploding):
		if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
			force.x -= WALK_FORCE
			stop = false
	elif (walk_right and velocity.y and not is_exploding):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
	
	if (stop and not is_exploding):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta

	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	if not is_exploding:
		motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		# You can check which tile was collision against with this
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		else:
			# For every other case of motion, our motion was interrupted.
			# Try to complete the motion by "sliding" by the normal
			
			motion = n.slide(motion)
			velocity_on_collision = velocity.y
			velocity = n.slide(velocity)
			# Then move again
			move(motion)
			if velocity_on_collision > 350:
				max_damage_supported -= 1
				take_damage()
				
	
	if (floor_velocity != Vector2()):
		# If floor moves, move with floor
		move(floor_velocity*delta)
	
	if (jump):
		
		if not jumping_animation and not get_node("AnimationPlayer").is_playing():
			jumping_animation = true
		
		if (not is_exploding and stamina_bar.get_staminabar_len() > 0.0):
			stamina_bar.update(stamina-.04)
			velocity.y = -JUMP_SPEED
		else:
			jumping_animation = false
			time_to_charge_again -= 1
			# get_node("s").set_scale(Vector2(.5, 1))
			# Jump must also be allowed to happen if the character left the floor a little bit ago.
			# Makes controls more snappy.
	else:
		if(stamina_bar.get_staminabar_len() <= 0.02):
			time_to_charge_again -= 1
		if(time_to_charge_again <= 0 or time_to_charge_again >= 10):
			time_to_charge_again = 10
			stamina_bar.update(stamina+.01)
			jumping_animation = false
	
	if (jumping_animation):
		if not animating_jump:
			get_node("AnimationPlayer").play("flying")
			animating_jump = true
	else:
		if animating_jump:
			get_node("AnimationPlayer").play("stopped")
			animating_jump = false
	
	if max_damage_supported <= 0 and not is_exploding:
		is_exploding = explode_spaceship()
	
	on_air_time += delta

func explode_spaceship():
	get_node("AnimationPlayer").play("exploding")
	yield(get_node("AnimationPlayer"), "finished")
	queue_free()
	return true

func take_damage():
	get_node("AnimationPlayer").play("takingDamage")
	yield(get_node("AnimationPlayer"), "finished")

func _ready():
	set_fixed_process(true)

