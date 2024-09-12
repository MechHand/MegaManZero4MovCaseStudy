class_name PlayerCamera extends Camera2D
## Class that moves the camera to the player.


@export var player : ZeroCharacter ## Reference to the player.
@export var camera_speed : float = 16.0 ## Speed used to vertically move the camera to the player.


func _process(delta: float) -> void:
	global_position.x = player.global_position.x
	global_position.y = (lerpf(global_position.y, player.global_position.y, camera_speed * delta))
