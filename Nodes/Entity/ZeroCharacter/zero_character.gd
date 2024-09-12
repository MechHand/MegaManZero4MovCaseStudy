class_name ZeroCharacter extends CharacterBody2D

@export_group("Movement Values")
@export_subgroup("Walk Values")
@export var base_speed : float = 120.0 ## The base movement speed of Zero (Guessed).
@export_subgroup("Jump Values")
@export var jump_force : float = -235.0 ## The base movement speed of Zero (Guessed).
@export var gravity : float = 220.0 ## The gravity applied in Zero (Guessed).
@export_range(0.1, 2.0, 0.05, "suffix:Seconds") var time_to_peak : float = 0.1 ## The time needed to reach the peak of the jump.
@export var max_fall_speed : float = 800.0 ## The maximum amount of fall speed allowed.
@export_subgroup("Slope Rules")
@export var min_y_velocity : float = -1.0 ## Velocity used to take into account to check if the player is jumping or not on top of a slope.
@export var slope_dot_margin : float = 0.333 ## Margin to be considered a slope, must be used in dot with a [code]Vector2.UP[/code]
@export_subgroup("Wall Rules")
@export var wall_dot_margin : float = 0.9  ## Margin to be considered an wall, must be used in dot with a [code]Vector2.RIGHT[/code]
@export_range(0.0, 1.0, 0.1, "suffix:Ratio") var wall_slowness_factor : float = 0.8 ## The factor of slow applied in the vertical velocity when sliding on an wall.
@export var wall_jump_max_time : float = 0.1 ## Maximum time allowed when doing an Wall Jump.
@export_subgroup("Dash Rules")
@export_range(1.2, 3.0, 0.1, "suffix:Multiplier") var dash_speed : float = 2.1 ## Speed multiplier applied in the base movement speed.
@export var dash_time : float = 0.4 ## Maximum time allowed when doing dash.

@export_group("Internal Nodes")
@export_subgroup("Slope Detection")
@export var ground_raycast_axis : Node2D ## Node to be used as an Axis to be mirrored.
@export var slope_detection : SlopeDetection ## Component that have all logic of slope detection.
@export_subgroup("Wall Detection")
@export var wall_raycast_axis : Node2D ## Node to be used as an Axis to be mirrored.
@export var wall_detection : WallDetection ## Component that have all logic of wall detection.
@export_subgroup("Graphics")
@export var sprite_node : AnimatedSprite2D ## Component that have all logic of sprite animations.

#region Unexposed Variables
# Wall jump variables
var current_wall_slowness : float = 1.0 ## The current applied slowness by wall interaction.
var on_wall_slide : bool = false ## Should be [code]true[/code] if the player is sliding on an wall. 
var on_wall_jump : bool = false ## Should be [code]true[/code] if the player is wall jumping. 
var last_wall_normal : Vector2 = Vector2.RIGHT ## The last detected wall normal value.
var current_wall_jump_time : float = 0.0 ## The time passed while wall jumping.

# Jump variables
var was_on_floor : bool = true ## Should be [code]true[/code] if the player was on the floor. 
var was_jumping : bool = false ## Should be [code]true[/code] if the player is in the air because of a Jump. 
var jump_input : bool = false ## Should be [code]true[/code] if the player is pressing the jump input. 
var can_jump : bool = false ## Should be [code]true[/code] if the player can jump. 
var is_jumping_time : float = 0.0 ## The time passed while jumping. 

# Dash variables
var current_dash_time : float = 0.0 ## The time passed while dashing.
var dash_input : bool = false ## Should be [code]true[/code] if the player is pressing the dash input. 
var on_dash : bool = false ## Should be [code]true[/code] if the player is dashing. 
var can_dash : bool = true ## Should be [code]true[/code] if the player can dash. 

# Walk variables
var h_input : float = 0.0 ## The axis of the horizontal input.
#endregion

signal MovementProcessed ## Signal emited after all physics logic of the player is alread applied.

func _ready() -> void:
	slope_detection._set_slope_verification(true)
	wall_detection._set_wall_verification(true)

## Main logic of the player.
func _physics_process(delta : float) -> void:
	h_input = Input.get_axis(&"MoveLeft", &"MoveRight")
	jump_input = Input.is_action_pressed(&"Jump")
	dash_input = Input.is_action_pressed(&"Dash")
	
	can_jump = is_on_floor() or on_wall_slide
	
	if ((was_jumping == false) and slope_detection._verify_if_near_ground()):
		slope_detection._snap_to_floor()
	
	_handle_walk(delta)
	_handle_jump(delta)
	
	if current_wall_jump_time > 0.0:
		current_wall_jump_time -= delta
	
	if not is_on_floor():
		wall_detection._wall_interaction(wall_detection._verify_if_wall_interaction())
		
		if is_jumping_time == 0.0 or is_jumping_time >= time_to_peak:
			velocity.y = move_toward(velocity.y, max_fall_speed, delta * gravity * 4) * current_wall_slowness
	else:
		current_wall_jump_time = 0.0
		on_wall_jump = false
	
	move_and_slide()
	MovementProcessed.emit()

## Function that takes care of all horizontal movement of the player.
func _handle_walk(delta : float) -> void:
	if h_input:
		# Dash Logic
		if dash_input and current_dash_time < dash_time and can_dash:
			current_dash_time = move_toward(current_dash_time, dash_time, delta)
			on_dash = true
		else:
			current_dash_time = move_toward(current_dash_time, 0.0, delta * 2.0)
			on_dash = false
			if is_zero_approx(current_dash_time):
				can_dash = true
			else:
				can_dash = false
		
		# Walk Logic
		if (not current_wall_jump_time > 0.0):
			var dash_multiplier : float = 1.0
			if on_dash == true:
				dash_multiplier = dash_speed
			
			velocity.x = (base_speed * dash_multiplier) * h_input
		
		sprite_node._handle_sprite_flip()
		_mirror_raycast_verification_to_direction()
	else:
		velocity.x = 0.0

## Verifies if there is [param jump_input] to change the [param velocity] in the Y Axis. This method does not change the horizontal velocity of the player.
func _handle_jump(delta : float) -> void:
	if jump_input:
		if is_jumping_time < time_to_peak and (velocity.y <= 0.0 or can_jump):
			if is_on_floor() or on_wall_slide:
				move_and_collide(Vector2.UP * 2.0)
				was_jumping = true
			is_jumping_time += delta
			velocity.y = jump_force
			
			if on_wall_slide == true:
				_wall_jump()
	else:
		if is_jumping_time < time_to_peak and was_jumping and velocity.y < 0.0:
			velocity.y *= is_jumping_time
		is_jumping_time = 0.0
	
	await get_tree().physics_frame # Needed to change a value with a 1 frame delay
	if is_on_floor():
		was_jumping = false


## Action of wall jump, impulses the player to up and against the wall.
func _wall_jump() -> void:
	var horizontal_direction : float = last_wall_normal.x
	
	on_wall_jump = true
	move_and_collide((Vector2.RIGHT * horizontal_direction) * 2.0)
	on_wall_slide = false
	
	current_wall_jump_time = wall_jump_max_time
	velocity.x = base_speed * horizontal_direction

## Mirrors the raycasts to only verify the direction of movement. This optimizes the use of raycasts. [br]
## ALERT : The initial position of raycasts must be at least in the positive X Axis.
func _mirror_raycast_verification_to_direction() -> void:
	var direction : float = 1.0
	if velocity.x < 0.0:
		direction = -1.0
	
	ground_raycast_axis.scale.x = direction
	wall_raycast_axis.scale.x = direction
