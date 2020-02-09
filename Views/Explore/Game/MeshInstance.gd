extends MeshInstance

onready var animationPlayer = get_node("AnimationPlayer")

func _ready():
	animationPlayer.play("Rotation")

