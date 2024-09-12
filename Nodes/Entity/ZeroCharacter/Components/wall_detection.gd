class_name WallDetection extends Node
## This class is used to detects valids walls to walljump using raycasts.

@export var zero : ZeroCharacter ## Reference to the Zero character (player).
@export var wall_raycasts : Array[RayCast2D] ## An array of raycasts used to verify any wall.

## Toggles on or off the wall verification.
func _set_wall_verification(toggle_to : bool) -> void:
	for raycast in wall_raycasts:
		raycast.enabled = toggle_to

## Verifies if there is any valid wall detected by the [param wall_raycasts].[br]
## During the verification, the [param zero.wall_dot_margin] from [ZeroCharacter] is taking account.
func _verify_if_wall_interaction() -> bool:
	var is_wall_interaction : bool = false
	
	if not zero.is_on_floor() and zero.velocity.y >= 0.0:
		for raycast in wall_raycasts:
			if raycast.is_colliding():
				var wall_normal : Vector2 = raycast.get_collision_normal().normalized()
				zero.last_wall_normal = wall_normal
				
				var wall_dot : float = absf(wall_normal.dot(Vector2.RIGHT))
				
				if wall_dot > zero.wall_dot_margin:
					is_wall_interaction = true
					return is_wall_interaction
	
	return is_wall_interaction

## If there is any interaction and [zero.h_input] is valid, the current wall slowness of the player is affected.
func _wall_interaction(is_interacting : bool) -> void:
	if not is_interacting:
		zero.current_wall_slowness = 1.0
		zero.on_wall_slide = false
	else:
		if zero.h_input:
			zero.current_wall_slowness = zero.wall_slowness_factor
			zero.on_wall_slide = true
		else:
			zero.current_wall_slowness = 1.0
			zero.on_wall_slide = false
