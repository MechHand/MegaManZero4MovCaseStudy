class_name ZeroSpriteManager extends AnimatedSprite2D
## Simple class to play animations. Has a simple state machine inside the [method _animate_player] function.


@export var zero : ZeroCharacter ## Reference to the Zero character (player).
@export_group("Animations")
@export var Idle : StringName = &"Idle" ## Idle animation name.
@export var Walk : StringName = &"Walk" ## Walk animation name.
@export var Jump : StringName = &"Jump" ## Jump animation name.
@export var Fall : StringName = &"Fall" ## Fall animation name.
@export var Dash : StringName = &"Dash" ## Dash animation name.


func _ready() -> void:
	if zero:
		zero.MovementProcessed.connect(_animate_player)

## Flip the sprite if the direction of movement of [zero] is negative.
func _handle_sprite_flip() -> void:
	flip_h = zero.velocity.x < -1.0

## Simple state machine that verify parameters to play animations.
func _animate_player() -> void:
	if zero.is_on_floor():
		if _is_idle():
			play(Idle)
		else:
			play(Walk)
	else:
		if _is_jumping():
			play(Jump)
		elif _is_falling():
			play(Fall)

## Checks if the [param zero] is on floor and moving.
func _is_idle() -> bool:
	return (zero.is_on_floor() and is_zero_approx(zero.velocity.x))

## Checks if the [param zero] is not on floor and have positive velocity in the Y Axis.
func _is_jumping() -> bool:
	return (not zero.is_on_floor() and zero.velocity.y < 0.0)

## Checks if the [param zero] is not on floor and have negative velocity in the Y Axis.
func _is_falling() -> bool:
	return (not zero.is_on_floor() and zero.velocity.y > 0.0)
