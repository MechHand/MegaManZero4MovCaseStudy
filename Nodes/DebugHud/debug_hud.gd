class_name DebugHud extends Node2D

@export var zero : ZeroCharacter
@export var debug_label : Label
@export var hide_show_debug_hud : Button

static var IsShow : bool = true
const BUTTON_TEXTS : Array[String] = ["Hide Debug Hud", "Show Debug Hud"]

const WALK : String = "Walk : "
const ONAIR : String = "On air : "
const ONSLOPE : String = "On Slope : "

func _ready() -> void:
	hide_show_debug_hud.pressed.connect(_toggle_visibility)
	_toggle_visibility()


func _process(delta: float) -> void:
	if is_visible():
		var is_walking : bool = absf(zero.velocity.x) > 0.1
		var is_jumping : bool = absf(zero.velocity.y) > 0.1
		var is_onslope : bool = zero.slope_detection._verify_if_near_ground()
		
		debug_label.text = str(
			WALK, is_walking, " (", snappedf(zero.velocity.x, 1.0), ")\n",
			ONAIR, is_jumping, " (", snappedf(zero.velocity.y, 1.0), ")\n",
			ONSLOPE, is_onslope
		)


func _toggle_visibility() -> void:
	if IsShow:
		hide()
	else:
		show()
	
	IsShow = not IsShow
	
	hide_show_debug_hud.text = BUTTON_TEXTS[int(!IsShow)]
	hide_show_debug_hud.release_focus()
