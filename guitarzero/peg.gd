extends RigidBody2D

@export var isHittable: bool = false;
@export var string: String = "";
@export var isHit: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (isHit):
		isHittable = false
		self.linear_velocity = Vector2(0,0)
		$Hit_Animation.play("Hit")

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Replace with function body.


func _on_hit_animation_animation_finished(_anim_name: StringName) -> void:
	queue_free() # Replace with function body.
