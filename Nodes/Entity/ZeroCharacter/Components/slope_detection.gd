class_name SlopeDetection extends Node
## This class is used to detects slopes and have methods to snap the player on floor.

@export var zero : ZeroCharacter ## Reference to the Zero character (player).
@export var slope_raycasts : Array[RayCast2D] ## An array of raycasts used to verify any slope.

## Toggles on or off the slope verification.
func _set_slope_verification(toggle_to : bool) -> void:
	for raycast in slope_raycasts:
		raycast.enabled = toggle_to

## Verifies if there is any valid slope detected by the [param slope_raycasts].[br]
## During the verification, the [param zero.slope_dot_margin] from [ZeroCharacter] is taking account.
func _verify_if_near_ground() -> bool:
	for raycast in slope_raycasts:
		if raycast.is_colliding():
			var slope_normal : Vector2 = raycast.get_collision_normal().normalized()
			var slope_dot : float = slope_normal.dot(Vector2.UP)
			
			if slope_dot > zero.slope_dot_margin and slope_dot < 1.0:
				return true
	return false

## Try to snap the [ZeroCharacter] in the floor, by simulating the movement towards the floor.
func _snap_to_floor() -> void:
	if not zero.is_on_floor() and zero.velocity.y >= zero.min_y_velocity:
		zero.move_and_collide(Vector2.DOWN * 32.0, false, 0.1, true)
		zero.velocity.y = absf(zero.velocity.x)
